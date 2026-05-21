# AppBase — Architecture

## Layers

| Folder | Role |
|--------|------|
| `AppBase/Data/Network/` | Alamofire — `APIService`, `APIEndpoint`, `BaseResponse`, `DataPage` |
| `AppBase/Domain/` | Model, Repo, Service, UseCase, factories |
| `AppBase/Presentation/` | Coordinator, ViewController, ViewModel (TIO*) |
| `AppBase/ThirdParty/` | Coordinator lib, EmptyDataSet, Shimmer, ESTabBar (không đặt app network ở đây) |

```
ViewModel → UseCase → Service → Repository → APIService
```

## DI

`AppDependencies` (tạo từ `AppCoordinator`):

| Property | Màn | Ghi chú |
|----------|-----|---------|
| `bankList` | Home | VietQR `https://api.vietqr.io/v2/banks` |
| `libraryRepository` | Library | Fake delay — demo shimmer |

DEBUG: `AppDependencies.make(useFakeData: false)` → API thật; `true` → bank fake offline.

## Login

**Chỉ demo UI** — không gọi API, không inject `AuthUseCase`. Onboarding/Register chuyển `AppState` thủ công.

## Main flow

`AppState.main` → **`FootballCoordinator`** (Lineup Builder). Legacy `MainCoordinator` / 5-tab ESTabBar không còn là root.

## Feedback

`trackError` / `trackSuccess` → **SwiftEntryKit** (`TIOEntryPresenter`). Toast success/error **không** mặc định mỗi API OK — bật qua `TrackableUseCaseInput.showsSuccessToast` / `bindUseCase(showsErrorToast:)`.

## Combine bags

| Type | Property |
|------|----------|
| `TIOViewModel` (+ subclasses) | `cancellables` — dùng chung, không khai báo lại trong VM con |
| `TIOViewController` | `cancelBag` |
| `Coordinator` | `cancelBag` |

## Agent skills

| Skill | Path |
|-------|------|
| UI / list / Kingfisher | `.cursor/skills/appbase-ios/` |
| Network / UseCase | `.cursor/skills/appbase-network/` |
| L10n | `.cursor/skills/appbase-localization/` |
| Ads | `.cursor/skills/appbase-ads/` |

## Samples

Xem `AppBase/Domain/Samples/README.md` — Home paging mẫu, không nằm trong DI.
