---
name: appbase-network
description: >-
  AppBase network & domain layer: APIService, APIEndpoint, BaseResponse, DataPage,
  Repository, Service, UseCase (TrackableUseCase), UseCasePublisher, DI
  (AppDependencies, RepoFactory, ServiceFactory). Use when adding API calls,
  endpoints, use cases, repositories, fake data, Combine publishers, APIError,
  or wiring ViewModel to network. Presentation bind → skill appbase-ios.
  UI copy → skill appbase-localization.
---

# AppBase Network & Domain

## Tách layer (không đặt trong `ThirdParty/`)

```
AppBase/
├── Data/Network/           ← transport (Alamofire)
│   APIService, APIServiceProtocol, APIEndpoint, APIConfiguration, APIError
│   BaseResponse, DataPage, UseCasePublisher
├── Domain/
│   Model/                  ← DTO (Bank, …)
│   Repo/ + Protocols/      ← gọi APIService, map response
│   Service/ + Protocols/   ← business entry (UseCase gọi Service)
│   UseCase/                ← execute + TrackableUseCase + bind VM
│   RepoFactory, ServiceFactory, UseCaseBinding.swift
└── Application/
    AppDependencies.swift   ← DI container
```

**Luồng chuẩn:**

```
ViewModel → UseCase → Service → Repository → APIService
```

**Không** gọi `APIService` trực tiếp từ ViewModel (trừ legacy `AuthUseCase` — feature mới theo pattern trên).

---

## APIService — khi nào dùng

| Dùng | Không dùng |
|------|------------|
| Chỉ trong **Repository** (hoặc infra tương đương) | ViewModel, ViewController, Coordinator |
| Inject `APIServiceProtocol` (test/fake) | `APIService.shared` rải rác (chỉ default param repo OK) |

### API có sẵn

```swift
// GET — decode type T (thường BaseResponse<Payload> hoặc payload thẳng)
api.get(.vietQRBanks) { (result: Result<BaseResponse<[Bank]>, APIError>) in
    completion(result.flatMap { $0.unwrap() })
}

// POST + JSON body
api.post(.login, body: LoginRequest(...)) { (result: Result<AuthResponse, APIError>) in
    ...
}
```

- Completion luôn trên **main thread** (đã xử lý trong `APIService`).
- Token: tự gắn `Authorization` từ `AppData.shared.token` nếu có.
- DEBUG: in CURL log.

### Thêm endpoint

1. `APIEndpoint` — case + `path` + `urlString` (base URL hoặc URL riêng, vd. VietQR):

```swift
case vietQRBanks

var urlString: String {
    switch self {
    case .vietQRBanks:
        return APIConfiguration.vietQRBaseURL + path
    default:
        return APIConfiguration.baseURL + path
    }
}
```

2. **Không** hardcode URL trong Repository — luôn qua `APIEndpoint`.

Files: `AppBase/Data/Network/APIService.swift`, `APIServiceProtocol.swift`, `APIEndpoint.swift`, `APIConfiguration.swift`.

---

## BaseResponse & DataPage

### `BaseResponse<T>` — envelope `{ code, data, message | desc }`

```swift
api.get(.vietQRBanks) { (result: Result<BaseResponse<[Bank]>, APIError>) in
    completion(result.flatMap { $0.unwrap() })
}
```

- Success codes mặc định: `"0"`, `"00"`, `"200"`, `"success"`.
- VietQR dùng `desc` → skill đã map `statusMessage`.
- Custom codes: `unwrap(successCodes: ["1000"])`.

### `DataPage<T>` — phân trang `{ pages, pageSize, total, list }`

```swift
typealias HomeListPage = DataPage<Int>
// page.items, page.canLoadMore
```

Repo decode `BaseResponse<HomeListPage>` rồi `unwrap()`.

**Chưa** gắn `unwrap` tự động trong `APIService` — unwrap tại Repository.

---

## UseCase — khi nào dùng

| Loại | Class | ViewModel bind |
|------|--------|----------------|
| Logic thuần (chỉ `execute`) | `UseCase<Input, Output>` | Tự subscribe publisher |
| Màn có loading + alert/list error | `TrackableUseCase<Input, Output>` | `bindUseCase(...)` |

### `TrackableUseCase` — pattern chuẩn

```swift
protocol GetBankListUseCaseProtocol: AnyObject {
    var isLoading: CurrentValueSubject<Bool, Never> { get }
    var didSucceed: PassthroughSubject<[Bank], Never> { get }
    var didFail: PassthroughSubject<TIOUserFacingError, Never> { get }
    func run(showsLoading: Bool)
}

final class GetBankListUseCase: TrackableUseCase<GetBankListUseCase.Input, [Bank]>,
                                  GetBankListUseCaseProtocol {

    private let service: BankServiceProtocol

    init(service: BankServiceProtocol) {
        self.service = service
        super.init()
    }

    func run(showsLoading: Bool = true) {
        run(Input(showsLoading: showsLoading))
    }

    override func execute(_ input: Input) -> AnyPublisher<[Bank], APIError> {
        service.getBanks()
    }

    override func shouldShowLoading(for input: Input) -> Bool {
        input.showsLoading  // false khi load more / silent refresh
    }

    struct Input: TrackableUseCaseInput {
        var showsLoading: Bool = true
        var showsSuccessToast: Bool = false
        var showsErrorToast: Bool = true
        var successToastMessage: String? = nil
    }
}
```

- **`execute`** — chỉ business + trả `AnyPublisher` (không đụng UI).
- **`run`** — bật `isLoading`, subscribe, phát `didSucceed` / `didFail`.
- **Input struct** — page, flags (`showsLoading`), filter, …

### ViewModel — `bindUseCase` + toast flags

`TIOViewModel.cancellables` — subclass **không** tạo Set riêng.

```swift
bindUseCase(
    useCase: bankListUseCase,
    storeIn: &cancellables,
    showsErrorToast: false,  // list: onFailure → EmptyDataSet, không trackError toast
    onSuccess: { [weak self] in self?.showBanks($0) },
    onFailure: { [weak self] in self?.showLoadError(message: $0.message) }
)

// Load list — không popup success (mặc định)
bankListUseCase.run(showsLoading: true)

// Có popup success khi cần
bankListUseCase.run(
    showsLoading: true,
    showsSuccessToast: true,
    successToastMessage: L10n.SomeFeature.saved
)
```

**Input** (`TrackableUseCaseInput`): `showsLoading`, `showsSuccessToast` (default **false**), `showsErrorToast`, `successToastMessage`.

**Toast:** `trackError` / `trackSuccess` trên VM — chi tiết bảng trong skill **`appbase-ios`** (Feedback).

File: `UseCaseBinding.swift`, `TrackableUseCaseInput.swift`.

**List screen:** `showsLoading: true` → skeleton; `false` → load more không full shimmer.

---

## Repository — bridge callback → Combine

```swift
func getBanks() -> AnyPublisher<[Bank], APIError> {
    UseCasePublisher.make { completion in
        self.api.get(.vietQRBanks) { (result: Result<BaseResponse<[Bank]>, APIError>) in
            completion(result.flatMap { $0.unwrap() })
        }
    }
}
```

`UseCasePublisher.make` = callback `Result` → `AnyPublisher` (tương đương Rx `Single`).

**Fake:** `BankFakeRepository` — delay + sample data; chọn qua `RepoFactory.makeBankRepository(useFake:)`.

---

## DI — thêm feature mới (checklist)

1. **Model** — `Domain/Model/YourModel.swift` (`Codable`).
2. **APIEndpoint** + path/url.
3. **RepositoryProtocol** + `YourRepository` (+ `YourFakeRepository`).
4. **ServiceProtocol** + `YourServiceImpl` (delegate repo).
5. **GetXxxUseCase** + `GetXxxUseCaseProtocol` kế thừa `TrackableUseCase`.
6. **RepoFactory** / **ServiceFactory** — factory method.
7. **AppDependencies** — property + wire trong `init(useFakeData:)`.
8. **Coordinator** — inject use case vào ViewModel.
9. **ViewModel** — `bindUseCase` + gọi `run`.

```swift
// AppDependencies (production inject)
let bankRepo = RepoFactory.makeBankRepository(useFake: useFakeData)
self.bankList = GetBankListUseCase(service: ServiceFactory.makeBankService(repository: bankRepo))
self.libraryRepository = LibraryFakeRepository()

// Coordinator
HomeViewModel(bankListUseCase: dependencies.bankList)
LibraryViewModel(repository: dependencies.libraryRepository)
```

DEBUG: `AppDependencies.make(useFakeData: false)` → VietQR thật; `true` → bank fake.

**Không inject:** `homeList` (mẫu paging — `Domain/Samples/`), **Login/Auth** (UI demo).

---

## APIError → UI

| Case | `userFacing` |
|------|----------------|
| `.business`, `.emptyData`, `.server` | message từ server / L10n |
| `.unauthorized` | không retry |
| `.network`, `.decoding`, … | `.generic` |

ViewModel list: `setListContentState(.error)` + EmptyDataSet retry; màn thường: `bindUseCase` → `presentError` mặc định.

---

## Ví dụ tham chiếu trong repo

| Feature | Files |
|---------|--------|
| VietQR banks (Home) | `Bank.swift`, `BankRepository`, `GetBankListUseCase`, `HomeViewModel`, `HomeBankCell` (logo → Kingfisher) |
| List phân trang (mẫu, không DI) | `Domain/Samples/` — `GetHomeListUseCase`, `HomeListPage` |
| Login | UI demo — `Presentation/Login/`, không `AppDependencies.auth` |

---

## Quy tắc (agent)

- **Repository** là nơi duy nhất gọi `api.get` / `api.post` cho feature mới.
- **UseCase** không import UIKit; output domain types hoặc `[Model]`.
- Mỗi UseCase public qua **protocol** để DI + fake test.
- Paginated list: dùng `DataPage` + `canLoadMore` / `hasReachedEnd()` ở VM — xem skill **appbase-ios** (list section).
- URL ảnh từ API (logo, avatar): model trả `URL?` / `String`; hiển thị bằng **Kingfisher** trong View/cell — skill **appbase-ios** (không tải ảnh trong Repository/UseCase).
- Không tạo generic `APIUseCase<T>` — một UseCase một màn/feature.

## Out of scope

- Không sửa Alamofire / `ThirdParty` trừ khi user yêu cầu.
- Tích hợp `BaseResponse` tự động trong `APIService` — user chưa bật; unwrap tại Repo.

## Files to consult

- Checklist: [checklist.md](checklist.md)
- Presentation bind / list: `.cursor/skills/appbase-ios/SKILL.md`
- L10n error strings: `.cursor/skills/appbase-localization/SKILL.md`
