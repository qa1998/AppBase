---
name: appbase-ios
description: >-
  Reviews and optimizes AppBase iOS presentation code (TIOViewController,
  TIOListViewController, TIOTableViewController, TIOListViewModel, TIOListView).
  Enforces SnapKit for all programmatic Auto Layout. Use when the user asks to
  review, refactor, optimize, add UI/layout, constraints, or list/screen features
  in AppBase, or mentions TIO, TIOView, TIOContentView, TIOTableViewCell, TIOCollectionViewCell,
  UITableViewCell, UICollectionViewCell, cellSize, cellHeight, custom UIView, SnapKit, snp, BaseMVVM, MJRefresh, EmptyDataSet,
  TIOPagingKit, TrackLoading, shimmer, skeleton loading, UIView-Shimmer, Font,
  FontSize, Lato typography, Spacing, Radius, ThemeManager, TIOThemable, palette, or dark/light mode,
  Coordinator, NavigationCoordinator, cancelBag, lazy tab, push/pop navigation.
  For ads (AdsKit, AdMob, banner, interstitial, rewarded), use skill `appbase-ads`.
  For APIService, UseCase, Repository, Service, BaseResponse, DataPage, DI — use skill
  `appbase-network`.   For remote images (URL → UIImageView), use **Kingfisher only** (`kf.setImage`).
  For error/success toasts, use **SwiftEntryKit** via `trackError` / `trackSuccess` on
  `TIOViewModel` (not UIAlert for normal errors). Project layout & DI: repo root
  `ARCHITECTURE.md`. For UI text and copy, use skill
  `appbase-localization` (L10n + SwiftGen) — never
  hardcode user-facing strings. **Every new view/screen must apply theme** (see below).
  When creating a custom `UIView` subclass, inherit **TIO*** common views (`TIOView`,
  `TIOContentView`, `TIOLabel`, …) — see section **Custom view (kế thừa TIO*)**.
---

# AppBase iOS Presentation

## Architecture (read first)

```
BaseViewController<VM>              // viewDidLoad → setupUI → onBind → viewModelDidReady
  └── TIOViewController<VM, Event>  // trackLoading + shimmer (TIOScreenViewController = TIOLoadingTarget)
        └── TIOListViewController<VM>
              ├── TIOTableViewController
              └── TIOCollectionViewController
```

List loading: shimmer **trong cell** (`shimmerHost`), không shimmer `listView`.

| Layer | Responsibility |
|-------|----------------|
| **ViewModel** | Data, `dataDidChange` / `dataDidInsert`, `hasReachedEnd()`, bind **UseCase** (không gọi APIService) |
| **List VC** | Bind subjects, MJRefresh, EmptyDataSet, **never** replace table `delegate` |
| **Table VC** | `registerNibs()`, `cellForRowAt` (override required), table delegate |
| **Collection VC** | `registerCells()`, `cellForItemAt` (override required), flow layout size |
| **Loading** | `trackLoading` → list: skeleton cells; màn thường: `shimmerViews(for:)` |

Lifecycle order matters: `BaseViewController.viewDidLoad` runs `setupUI` **before** subclass `viewDidLoad` adds `containerView`.

## UI views (TIO*)

```
TIOView                    // base + ShimmeringViewProtocol
├── TIOContentView         // IFSContentView, shimmeringAnimatedItems = [] (no shimmer shell)
├── TIOLabel / TIOButton   // ShimmeringViewProtocol
├── TIOTableViewCell       // shimmerHost pin full width — dùng cho list loading
└── TIOCollectionViewCell  // shimmerHost edges = contentView
```

**Không** gọi `setTemplateWithSubviews` trực tiếp trên `UITableViewCell` / toàn cell — sẽ shimmer `textLabel` và bị lệch trái. Luôn dùng `applyListShimmer(_:)`.

## List cells (`TIOTableViewCell` / `TIOCollectionViewCell`)

Mỗi row/item list **ưu tiên subclass** `TIOTableViewCell` hoặc `TIOCollectionViewCell` — **không** `UITableViewCell` / `UICollectionViewCell` thuần (mất theme + `applyListShimmer` + `shimmerHost`).

| Loại | Base cell | API tính kích thước dynamic | Ai gọi |
|------|-----------|----------------------------|--------|
| **Table** | `TIOTableViewCell` | `class func cellHeight(for data: Any?) -> CGFloat` | Subclass VC override `heightForRowAt` → gọi `MyCell.cellHeight(for: viewModel.item(at:))` |
| **Collection** | `TIOCollectionViewCell` | `class func cellSize(data: Any?) -> CGSize` | `TIOCollectionViewController` gọi sẵn trong `sizeForItemAt` |

**Không** hardcode `72` / `56` trong ViewController — logic height/size nằm trên **cell class** (theo `data` từng row).

### Table — `cellHeight(for:)`

```swift
final class FeedCell: TIOTableViewCell {

    private let bodyLabel = TIOLabel()

    override func commonInit() {
        super.commonInit()
        contentView.addSubview(bodyLabel)
        bodyLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.s16)
        }
    }

    func configure(with item: FeedItem) {
        bodyLabel.text = item.body
    }

    override class func cellHeight(for data: Any?) -> CGFloat {
        guard let item = data as? FeedItem else { return 56 }
        let width = UIScreen.main.bounds.width - Spacing.s16 * 2
        let textHeight = (item.body as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: Font.default(size: .text17)],
            context: nil
        ).height
        return ceil(textHeight) + Spacing.s16 * 2
    }
}

// ViewController
override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if viewModel.isListCellLoading {
        return FeedCell.cellHeight(for: nil)  // chiều cao skeleton ổn định
    }
    return FeedCell.cellHeight(for: viewModel.item(at: indexPath))
}
```

- `dequeueListCell(_:from:for:)` (base) đã gọi `applyListShimmerIfNeeded` — ưu tiên dùng helper này.
- `registerCellClasses()` / `registerNibs()` → `[MyCell.self]`; configure trong `cellForRowAt` qua `configure(with:)`.
- Chỉ dùng `UITableView.automaticDimension` khi cell self-sizing hoàn toàn bằng constraints; vẫn nên có `cellHeight` cho skeleton loading.

### Collection — `cellSize(data:)`

```swift
final class BannerCell: TIOCollectionViewCell {

    override func setupLayout() {
        // SnapKit subviews trong contentView
    }

    override func updateDisplay(data: Any?) {
        // bind model
    }

    override class func cellSize(data: Any?) -> CGSize {
        guard let banner = data as? Banner else {
            return CGSize(width: UIScreen.main.bounds.width, height: 120)
        }
        let width = UIScreen.main.bounds.width
        let aspect: CGFloat = banner.imageHeight / max(banner.imageWidth, 1)
        return CGSize(width: width, height: width * aspect)
    }
}

override func registerCells() -> [TIOCollectionViewCell.Type] { [BannerCell.self] }
```

- Base `sizeForItemAt` lấy `registerCells().first` → mỗi VC **một cell type** hoặc override `sizeForItemAt` khi nhiều loại cell (gọi đúng `CellType.cellSize(data:)` theo indexPath).
- `cellSize` trả `.zero` → fallback full width × `56` (tránh layout 0); production **luôn** trả size hợp lệ theo `data`.
- Skeleton loading: `applyListShimmer` trong `cellForItemAt`; `cellSize(for: nil)` nên trả chiều cao placeholder cố định.

### Cell subclass checklist

- [ ] Kế thừa `TIOTableViewCell` / `TIOCollectionViewCell`
- [ ] Theme: override `applyTheme` + `super`; subview = `TIOLabel` / `TIOView`
- [ ] Shimmer: `applyListShimmer` từ VC / `dequeueListCell` — không shimmer root cell
- [ ] Dynamic size: `cellHeight(for:)` (table) hoặc `cellSize(data:)` (collection) — không magic number trong VC
- [ ] `prepareForReuse`: cancel Kingfisher, reset UI

Files: `TIOTableViewCell.swift`, `TIOCollectionViewCell.swift`, `TIOTableViewController.swift`, `TIOCollectionViewController.swift`.

## Custom view (kế thừa TIO* common views)

Mỗi `UIView` custom trong AppBase **ưu tiên subclass** một common view đã có — **không** `UIView` / `UILabel` / `UIButton` thuần rồi tự `bindTheme` trừ khi wrap third-party không sửa được.

### Chọn base class

| Cần | Kế thừa | Ghi chú |
|-----|----------|---------|
| Khối UI có theme + shimmer (header, card, banner, form block) | `TIOView` | `shimmeringAnimatedItems` mặc định `[self]` |
| Container full màn / bọc list (`containerView`) | `TIOContentView` | `IFSContentView` → VC tự pin edges; **không** shimmer shell |
| Chỉ text | `TIOLabel` | Font + `textPrimary` sẵn; override `applyTheme` nếu cần màu khác |
| Nút / CTA | `TIOButton` | CTA: `usesFilledPrimaryStyle = true` trong `commonInit` |
| Row list | `TIOTableViewCell` / `TIOCollectionViewCell` | Shimmer qua `applyListShimmer`, không subclass `UITableViewCell` thuần |
| Third-party view không subclass được | `UIView` + `bindTheme { }` | Chỉ ngoại lệ |

### Khởi tạo — luôn qua `commonInit`

`TIOView` / `TIOLabel` / `TIOButton` gọi `commonInit()` từ cả `init(frame:)` và `init(coder:)`. Subclass:

1. **Không** gọi lại `startTheming()` — base đã gọi trong `commonInit`.
2. Override `commonInit()` → **`super.commonInit()` trước**, rồi `addSubview`, SnapKit, style.
3. Override `applyTheme(_:)` → **`super.applyTheme(colors)`** nếu cần giữ hành vi base (vd. `TIOContentView` nền), rồi set màu riêng.

```swift
final class ProfileHeaderView: TIOView {

    private let avatarView = TIOView()
    private let nameLabel = TIOLabel()

    override func commonInit() {
        super.commonInit()
        addSubview(avatarView)
        addSubview(nameLabel)
        avatarView.layer.cornerRadius = Radius.s20
        avatarView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.s16)
            make.width.height.equalTo(80)
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(Spacing.s12)
            make.trailing.equalToSuperview().inset(Spacing.s16)
            make.centerY.equalTo(avatarView)
        }
    }

    override func applyTheme(_ colors: ThemeColors) {
        super.applyTheme(colors)
        avatarView.backgroundColor = colors.backgroundPrimary
        layer.borderColor = colors.separator.cgColor
    }

    func configure(name: String) {
        nameLabel.text = name  // copy từ ngoài hoặc L10n — không hardcode trong view
    }
}
```

### Subview bên trong custom view

- Layout con: **SnapKit** trong `commonInit` (hoặc `setupViews()` gọi từ `commonInit`).
- Con UIKit: **`TIOLabel` / `TIOButton` / `TIOView`** — không `UILabel`/`UIButton` thuần.
- Màu: **`ThemeColors`** trong `applyTheme` — không `.label`, `.white`, `.systemBackground`.
- Typography: **`Font` + `FontSize`** — không `UIFont.systemFont`.
- Spacing / radius: **`Spacing.*`**, **`Radius.*`**.

### Shimmer trên custom `TIOView`

- Vùng shimmer non-list: VC map trong `shimmerViews(for:)` → trả về instance `TIOView` / `TIOLabel` (hoặc custom `TIOView` subclass).
- Composite view nhiều vùng: override `shimmeringAnimatedItems` (vd. `[titleLabel, imageView]`) hoặc `excludedItems` để bỏ nút/icon.
- **Không** shimmer `TIOContentView` — override `shimmeringAnimatedItems` → `[]` (đã có trên `TIOContentView`).
- **Không** `setTemplateWithSubviews` tay trên cell — dùng `applyListShimmer`.

### `TIOContentView` vs `TIOView` trong VC

```swift
// Màn list / full content — container không shimmer
private let containerView = TIOContentView()

// Khối cần shimmer riêng (header, card)
private let headerView = ProfileHeaderView()
```

Trong `TIOViewController`: subview conform `IFSContentView` được `layoutIFSContentViewsIfNeeded()` pin full bounds — dùng cho nib hoặc `TIOContentView` add sớm.

### Anti-patterns

```swift
// ❌ UIView thuần + bindTheme trùng logic TIOView
final class CardView: UIView {
    init() { super.init(...); bindTheme { ... } }  // dùng TIOView subclass
}

// ❌ startTheming() lần hai trong subclass TIOView
override func commonInit() {
    startTheming()  // base đã gọi
}

// ❌ Hardcode màu trong commonInit
override func commonInit() {
    super.commonInit()
    backgroundColor = .white  // → applyTheme + palette
}
```

Files: `AppBase/Core/UI/Foundation/Views/TIOView.swift`, `TIOContentView.swift`, `TIOLabel.swift`, `TIOButton.swift`, `TIOThemable.swift`.

## Remote images — **Kingfisher only**

SPM: `Kingfisher` (đã link trong `AppBase.xcodeproj`). **Chỉ** dùng Kingfisher để load ảnh từ URL — **không** `URLSession.dataTask`, `Data(contentsOf:)`, hay cache ảnh tự viết.

| Dùng | Không dùng |
|------|------------|
| `imageView.kf.setImage(with:placeholder:options:)` | `URLSession` + `UIImage(data:)` cho avatar/logo/banner |
| `imageView.kf.cancelDownloadTask()` trong `prepareForReuse` | Giữ request cũ khi cell reuse |
| `UIImageView`, `UIButton` (KF extension) | Tải ảnh trong ViewModel |

### UIKit — cell / image view

```swift
import Kingfisher

// Load
imageView?.contentMode = .scaleAspectFit
imageView?.kf.setImage(
    with: url,  // URL? — nil → chỉ placeholder
    placeholder: UIImage(systemName: "building.2"),
    options: [.transition(.fade(0.2)), .cacheOriginalImage]
)

// Reuse (UITableView / UICollectionView)
override func prepareForReuse() {
    super.prepareForReuse()
    imageView?.kf.cancelDownloadTask()
    imageView?.image = placeholder
}
```

- URL từ model (vd. `Bank.logoURL`) — ViewModel chỉ truyền model/URL, **cell** gọi `kf.setImage`.
- Placeholder: SF Symbol hoặc asset local; không để imageView trống khi đang load.
- Shimmer list: vẫn `applyListShimmer` — khi hết loading mới `configure` + Kingfisher.

### SwiftUI (nếu cần)

```swift
import Kingfisher

KFImage(url)
    .placeholder { ProgressView() }
    .fade(duration: 0.2)
    .resizable()
    .scaledToFit()
```

### Tham chiếu

- Demo: `HomeBankCell` — logo ngân hàng VietQR.
- Docs: [Kingfisher](https://github.com/onevcat/Kingfisher).

## Feedback — SwiftEntryKit (`trackError` / `trackSuccess`)

SPM: `SwiftEntryKit`. Toast **top** (`EKAttributes.topFloat`), theme `ThemeManager`.

### `TIOViewModel` publishers

| Publisher / API | Khi nào |
|-----------------|--------|
| `trackError` → `presentError` | Toast lỗi (đỏ) — **không** phải lúc nào fail cũng toast |
| `trackSuccess` → `presentSuccess` | Toast thành công — **chỉ khi bật** (xem bảng dưới) |
| Gọi tay `presentError` / `presentSuccess` | Ads, nút test, hành động user rõ ràng |

`TIOViewController.onBind` subscribe `trackError` + `trackSuccess` → `TIOEntryPresenter`.

### Khi nào toast tự bật (UseCase + `bindUseCase`)

Flags trên **`TrackableUseCaseInput`** (mỗi lần `run`), giống `showsLoading`:

| Flag | Mặc định | Ý nghĩa |
|------|----------|---------|
| `showsLoading` | `true` | Skeleton / shimmer |
| `showsSuccessToast` | **`false`** | `true` + `successToastMessage` → toast success sau `onSuccess` |
| `showsErrorToast` | `true` | `true` + không có `onFailure` → `presentError` |
| `successToastMessage` | `nil` | Copy toast success (L10n) |

`bindUseCase` thêm `showsErrorToast: Bool = true` — tắt nếu list/empty state xử lý lỗi (`showsErrorToast: false` + `onFailure`).

```swift
// List Home — không toast lỗi/success khi load bank (chỉ EmptyDataSet)
bindUseCase(
    useCase: bankListUseCase,
    storeIn: &cancellables,
    showsErrorToast: false,
    onSuccess: { self?.showBanks($0) },
    onFailure: { self?.showLoadError(message: $0.message) }
)
bankListUseCase.run(showsLoading: true)  // showsSuccessToast mặc định false

// Lưu form — có toast success
getProfileUseCase.run(
    showsLoading: true,
    showsSuccessToast: true,
    successToastMessage: L10n.Profile.saved
)

// Ads / test — gọi tay
presentSuccess(L10n.Scripts.Ads.success("Banner loaded"))
```

- **Không** `UIAlertController` cho lỗi thường — `showTIOAlert` chỉ retry dialog.
- Files: `TrackError.swift`, `TIOEntryPresenter.swift`, `TrackableUseCaseInput.swift`, `UseCaseBinding.swift`.

## Typography (`Font` + `FontSize`)

Lato đã khai báo trong `Info.plist` (`UIAppFonts`). **Không** dùng `UIFont.systemFont`, `.font(.system(...))`, hay magic số size trực tiếp trong code AppBase (trừ `ThirdParty/`).

| API | Dùng khi |
|-----|----------|
| `Font.default(size:)` | body, subtitle, input |
| `Font.bold(size:)` | title, button, nav bar |
| `Font.italic(size:)` | emphasis / link style |
| `Font.swiftUIFont(_:style:)` | SwiftUI `Text` / `Image` |
| `FontSize` token | `.text34` … `.text10`, semantic `.titles`, `.buttons`, `.custom(38)` |

```swift
// UIKit
titleLabel.font = Font.bold(size: .text28)
subtitleLabel.font = Font.default(size: .subtitle)
titleLabel?.font = Font.bold(size: .buttons)  // TIOButton.commonInit

// SwiftUI — enum `Font` (AppBase), không phải SwiftUI.Font.system
Text(L10n.App.name)
    .font(Font.swiftUIFont(.text34, style: .bold))
Text(tagline)
    .font(Font.swiftUIFont(.text22))
```

- Ưu tiên token có sẵn (`.text17`, `.text22`, …); size lẻ → `.custom(CGFloat)`.
- `NavigationAppearance` đã dùng `Font.bold(size: .text17)` — giữ cùng pattern.
- Semibold/medium system weight → map sang Lato **bold** hoặc **default** (không có Lato-Semibold).

Files: `AppBase/Core/Font/Font.swift`, `FontSize.swift`, `Font+SwiftUI.swift`.

## Spacing & Radius (layout tokens)

**Không** magic number cho padding / margin / khoảng cách giữa view / bo góc trong AppBase (trừ `ThirdParty/`).

| Enum | Dùng cho | Tokens |
|------|----------|--------|
| `Spacing` | `offset`, `inset`, `VStack`/`HStack` spacing, `UIStackView.spacing`, `.padding` SwiftUI | `s4` … `s40` (`s8`, `s12`, `s16`, `s20`, `s24`, `s28`, `s32`, …) |
| `Radius` | `layer.cornerRadius`, `.cornerRadius`, `RoundedRectangle(cornerRadius:)` | `s8`, `s12`, `s16`, `s20` |

```swift
// UIKit + SnapKit
titleLabel.snp.makeConstraints { make in
    make.top.equalToSuperview().offset(Spacing.s24)
    make.leading.trailing.equalToSuperview().inset(Spacing.s20)
}
button.layer.cornerRadius = Radius.s12
stack.spacing = Spacing.s12

// SwiftUI
VStack(spacing: Spacing.s24) { ... }
    .padding(.horizontal, Spacing.s20)
    .padding(.bottom, Spacing.s40)
RoundedRectangle(cornerRadius: Radius.s20, style: .continuous)
```

- Cần giá trị mới → **thêm token** vào `Spacing.swift` / `Radius.swift` (đặt tên `sN` theo pt), không hardcode `16`, `12` rải rác.
- **Không** constraint `height`/`width` từng button trong `UIStackView` — set `stack.spacing = Spacing.*` + height cho stack.
- Chiều cao row/button cố định (48pt) có thể giữ constant riêng nếu không có token `Spacing` tương ứng.

Files: `AppBase/Core/Layout/Spacing.swift`, `Radius.swift`.

## Theme (`ThemeManager` + TIO common views) — **bắt buộc mỗi view mới**

`ThemeManager.shared.palette` (`@Published`) — đổi `mode` hoặc system appearance → UI tự cập nhật qua `bindTheme` / `startTheming()`.

### Quy tắc vàng

1. **UIKit UI** → dùng `TIOView` / `TIOLabel` / `TIOButton` / `TIOContentView` / cell `TIOTableViewCell` — **không** `UIView` / `UILabel` / `UIButton` thuần trừ khi wrap và gọi `bindTheme`.
2. **Màn hình** → subclass `TIOViewController` (hoặc list/table/collection base) — **không** set `view.backgroundColor = .systemBackground` / `.white`.
3. **Màu** → chỉ lấy từ `ThemeManager.shared.palette` (hoặc `colors`) — **không** `.label`, `.systemBackground`, `.white`, `.black` cho nền/chữ chính.
4. **SwiftUI** → `@ObservedObject private var themeManager = ThemeManager.shared` + `Color(uiColor: themeManager.palette.*)`.
5. **Shimmer** → `viewBackgroundColor` từ `palette.backgroundSecondary`, không hardcode.

### Mapping màu (`ThemeColors`)

| Token | Dùng cho |
|-------|----------|
| `backgroundPrimary` | Card, nav/tab bar nền, cell nền |
| `backgroundSecondary` | Màn full (`TIOViewController.view`), `TIOContentView` |
| `textPrimary` | Title, body (`TIOLabel`) |
| `textSecondary` | Subtitle, caption |
| `primary` | CTA, tint, tab selected |
| `separator` | Divider |

### TIO views (tự theme qua `TIOThemable`)

| View | Hành vi |
|------|---------|
| `TIOView` | `startTheming()` trong `commonInit`; override `applyTheme` nếu cần màu riêng |
| `TIOContentView` | `backgroundSecondary` |
| `TIOLabel` | `textPrimary` + `Font.default(size: .text17)` |
| `TIOButton` | `primary`; CTA: `usesFilledPrimaryStyle = true` |
| `TIOTableViewCell` / `TIOCollectionViewCell` | nền + `textLabel` colors + shimmer nền |
| `TIOViewController` | `view` = `backgroundSecondary`; `traitCollectionDidChange` → `refreshPaletteIfNeeded()` |

```swift
// Custom UIView không có subclass TIO* — bắt buộc bindTheme
final class ProfileHeaderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        bindTheme { [weak self] colors in
            self?.backgroundColor = colors.backgroundPrimary
        }
    }
}

// Subclass TIOView — override applyTheme
final class BannerView: TIOView {
    override func applyTheme(_ colors: ThemeColors) {
        backgroundColor = colors.backgroundPrimary
        layer.borderColor = colors.separator.cgColor
    }
}
```

### SwiftUI màn mới

```swift
struct FeatureView: View {
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        ScrollView { /* ... */ }
            .background(Color(uiColor: themeManager.palette.backgroundSecondary))
    }
}
```

Nav/tab bar: `AppAppearance.shared.applyIncludingVisibleBars()` đã gọi từ `ThemeManager.updatePalette()` — không cần set tay trên từng màn.

Files: `AppBase/Core/Theme/`, `UIView+Theme.swift`, `TIOThemable.swift`.

## Adding a new screen (theme + localization checklist)

Dùng **mỗi lần** tạo ViewController / SwiftUI view / custom `UIView` mới:

```
- [ ] VC kế thừa TIOViewController / TIOListViewController / TIOTableViewController (không BaseViewController trực tiếp nếu có UI)
- [ ] Subview UIKit: TIOLabel, TIOButton, TIOContentView, TIOView (không UILabel/UIButton thuần)
- [ ] Không .systemBackground / .white / .label cho nền & chữ chính
- [ ] CTA: TIOButton + usesFilledPrimaryStyle = true
- [ ] Custom UIView: subclass `TIOView` / `TIOContentView` / `TIOLabel` / `TIOButton` (xem **Custom view (kế thừa TIO*)**); `bindTheme` chỉ khi không subclass TIO* được
- [ ] Subclass TIO*: `super.commonInit()` + `super.applyTheme`; không gọi `startTheming()` lại
- [ ] SwiftUI: @ObservedObject themeManager + palette colors
- [ ] title / strings: L10n + override refreshLocalization() (skill appbase-localization)
- [ ] Font: Font.default / Font.bold + FontSize (không systemFont)
- [ ] Spacing / Radius cho padding & cornerRadius (không magic 8, 12, 16, 20…)
- [ ] Có điều hướng sang màn khác → Coordinator + subject action (không push/pop trực tiếp từ VC)
```

### ViewController template

```swift
final class FeatureViewController<VM: FeatureViewModel>: TIOScreenViewController<VM> {

    private let contentView = TIOContentView()
    private let titleLabel = TIOLabel()

    override func viewDidLoad() {
        super.viewDidLoad()  // đã bind theme + localization
        refreshLocalization()
    }

    override func setupUI() {
        super.setupUI()
        view.addSubview(contentView)
        contentView.addSubview(titleLabel)
        // SnapKit...
    }

    override func refreshLocalization() {
        title = L10n.Feature.title
        titleLabel.text = L10n.Feature.subtitle
    }
}
```

`TIOViewController` đã gọi `bindScreenTheme()` và `bindLocalization()` — **không** duplicate trừ khi cần thêm observer riêng.

## Coordinator (navigation) — **bắt buộc khi có flow màn**

AppBase dùng `Coordinator<M: CoordinationMeta>` + `NavigationCoordinator<VoidMeta>` (`AppBase/ThirdParty/Coordinator/`).

### Quy tắc vàng

1. **Navigation chỉ trong Coordinator** — `push` / `pop` / `set` / `present` qua `navigate(to:)`. **Không** gọi `navigationController?.pushViewController` / `popViewController` từ VC feature (trừ `onBackPress` test hoặc user yêu cầu ngoại lệ).
2. **VC / ViewModel chỉ bắn action** — `PassthroughSubject` (hoặc publisher trên VC như Login). Coordinator `sink` và gọi `navigate`.
3. **`cancelBag` trên base `Coordinator`** — `open class Coordinator` đã có `var cancelBag`. Subclass **dùng `&cancelBag`**, **không** khai báo `private var cancelBag` trùng.
4. **Generic type** — khai báo `Coordinator<VoidMeta>`, `NavigationCoordinator<VoidMeta>` (meta: `struct VoidMeta` trong `AppCoordinator.swift`).
5. **`rootVC` lazy** — tạo VC + VM, bind navigation subjects, `invoke(viewModel:)`, return VC; `start()` → `navigate(to: .set([rootVC]))`.

### Bind navigation trong Coordinator

```swift
class FeatureCoordinator: NavigationCoordinator<VoidMeta> {

    private lazy var rootVC: UIViewController = {
        let viewController = FeatureViewController()
        let viewModel = FeatureViewModel()
        viewModel.openDetail
            .sink { [weak self] id in
                self?.pushDetail(id: id)
            }
            .store(in: &cancelBag)  // cancelBag từ Coordinator base
        viewController.invoke(viewModel: viewModel)
        return viewController
    }()

    override func start() {
        super.start()
        navigate(to: .set([rootVC]), transitioning: .none)
    }

    private func pushDetail(id: String) {
        let viewController = DetailViewController()
        let viewModel = DetailViewModel(id: id)
        bindDetailNavigation(viewModel)  // bind mỗi màn push mới nếu màn đó cũng bắn action
        viewController.invoke(viewModel: viewModel)
        navigate(to: .push(viewController))
    }
}
```

### Màn con cũng bắn action → cùng Coordinator

Khi push màn test / detail, bind thêm subject **trước** `invoke` + `push`:

```swift
enum DetailNavigation {
    case pop
    case push(step: Int)
}

final class DetailViewModel: TIOViewModel<TIOLoadingTarget> {
    let navigationAction = PassthroughSubject<DetailNavigation, Never>()
    func requestPop() { navigationAction.send(.pop) }
}

private func bindDetailNavigation(_ viewModel: DetailViewModel) {
    viewModel.navigationAction
        .sink { [weak self] action in
            switch action {
            case .pop: self?.navigate(to: .pop)
            case let .push(step): self?.pushTestScreen(step: step)
            }
        }
        .store(in: &cancelBag)
}
```

**VC test:** nút chỉ gọi `viewModel.requestPop()` — không `navigationController`.

### Tham chiếu trong repo

| Flow | File | Pattern |
|------|------|---------|
| Login → Register | `LoginCoordinator`, `LoginViewController` | `navToRegister` trên **VC** → coordinator `push` |
| Record → Test | `RecordCoordinator`, `RecordViewModel` | `pushTestScreen` trên **VM** → coordinator `push` |
| Test pop/push lại | `RecordTestViewModel`, `RecordTestNavigation` | enum action → coordinator `pop` / `push` |

### Main tab bar — lazy coordinator

`MainViewController`: **5 `UINavigationController` cố định** + **5 coordinator `start()` ngay trong `viewDidLoad`** (không lazy / placeholder / preload). Giữ mảng `coordinators` để retain coordinator. `syncESTabBarHighlight` trong `viewDidAppear` / `didSelect`.

Tab coordinator: `private lazy var rootVC` — root màn tạo khi `coordinator.start()`.

## TrackLoading + shimmer

### Types

```swift
enum TrackLoading<Event> {
    case start(Event)
    case stop(Event)
}

enum TIOLoadingTarget: Hashable { case screen }  // list loading mặc định

class TIOViewModel<Event: Hashable>: BaseViewModel {
    var cancellables = Set<AnyCancellable>()  // subclass dùng chung — không khai báo lại
    let trackLoading = PassthroughSubject<TrackLoading<Event>, Never>()
    let trackError, trackSuccess  // → SwiftEntryKit (TIOViewController)
    func startLoading(_ event: Event)
    func stopLoading(_ event: Event)
}

// List VM
extension TIOViewModel where Event == TIOLoadingTarget {
    func startLoading()  // .start(.screen)
    func stopLoading()
}

typealias TIOScreenViewController<VM> = TIOViewController<VM, TIOLoadingTarget>
    where VM: TIOViewModel<TIOLoadingTarget>
```

**Không** dùng `TIOViewModel<Event = ...>` (Swift không hỗ trợ default generic trên class). List: `TIOViewModel<TIOLoadingTarget>` / `TIOListViewModel`.

### List screen — shimmer trong cell (bắt buộc)

**Không** shimmer `tableView` / `collectionView`. `TIOListViewController`:

- `shimmerViews` → `[]`
- `handleTrackLoading(.screen)` → `setListCellLoading` + `reloadData` + shimmer visible cells
- `displayItemCount(in:)` → `skeletonPlaceholderCount` (8) khi `isListCellLoading`
- `emptyDataSetShouldDisplay` → `false` khi `isListCellLoading` (đang có skeleton rows)

**ViewModel (fetch / refresh):**

```swift
override func refreshAndGetListData() {
    startLoading()          // skeleton rows + shimmer cell
    fakeAPI.fetch { [weak self] in
        DispatchQueue.main.async {
            guard let self else { return }
            self.items = response.items
            self.dataDidChange.send()
            self.stopLoading()
        }
    }
}
```

**Không** gọi `startLoading()` cho `loadMoreData` — chỉ MJRefresh footer.

**ViewController `cellForRowAt` / `cellForItemAt`:**

```swift
let cell = tableView.dequeueReusableCell(type: TIOTableViewCell.self, for: indexPath)
if viewModel.isListCellLoading {
    cell.applyListShimmer(true)
} else {
    cell.applyListShimmer(false)
    // configure UI thật
}
return cell
```

**Cell registration & height:**

- Programmatic: `registerCellClasses() -> [MyCell.self]`; Nib: `registerNibs()`
- **Dequeue** bắt buộc — `dequeueListCell` / `dequeueReusableCell(type:for:)`; không `TIOTableViewCell()` tay
- Dynamic height: override `MyCell.cellHeight(for:)`; VC `heightForRowAt` → gọi `cellHeight` (kể cả khi `isListCellLoading`) — xem **List cells**
- Collection: override `cellSize(data:)` — base VC đã delegate `sizeForItemAt`

### Non-list screen — shimmer theo vùng

```swift
enum ProfileLoadingEvent: Hashable { case header, form }

class ProfileViewModel: TIOViewModel<ProfileLoadingEvent> { ... }

class ProfileViewController: TIOViewController<ProfileViewModel, ProfileLoadingEvent> {
    override func shimmerViews(for event: ProfileLoadingEvent) -> [UIView] {
        switch event {
        case .header: return [titleLabel, avatarView]  // TIOLabel / TIOView
        case .form: return [formStack]
        }
    }
}
```

`startLoading(.header)` / `stopLoading(.header)` — VC giữ `Set` active events, không shimmer chồng nhầm.

### Network / UseCase (ViewModel)

ViewModel **không** gọi `APIService` trực tiếp. Inject `GetXxxUseCaseProtocol`, `bindUseCase`, gọi `run`:

```swift
bankListUseCase.run(showsLoading: true)
```

Chi tiết APIService, Repository, TrackableUseCase, DI → skill **`appbase-network`**.

Files: `TrackLoading.swift`, `TIOViewModel.swift`, `TIOViewController.swift`, `TIOListViewModel.swift`, `TIOListViewController.swift`, `Domain/UseCaseBinding.swift`.

## Before changing code

1. Read files under `AppBase/Presentation/Foundation/` and `AppBase/Core/UI/ListView/`.
2. Grep usages of the type you change (`hasReachedEnd`, `dataDidInsert`, subclasses).
3. Prefer minimal diffs; match existing naming (`TIO*`, `onBind`, `setupUI`).

## Critical rules (do not break)

### UITableView delegate

- `TIOTableViewController` sets `tableView.delegate = self` for `UITableViewDelegate`.
- **Never** set `listView.delegate` in `TIOListViewController` — it overwrites table delegate and breaks `didSelectRow`, heights, headers.

### Pagination naming

- Use `hasReachedEnd() -> Bool`: `true` = no next page → call `endLoadMoreWithNoData()`.
- Do **not** use inverted names like `canLoadMore()` that return `true` to mean “stop loading”.
- Full reload: `dataDidChange.send()` — end refresh + `resetNoMoreData()`; end footer if `isLoadMore`.
- Append: `dataDidInsert.send((start:count:))` — use `IndexPath(row:section:)` for tables.

### Combine / memory

| Layer | Bag | Ghi chú |
|-------|-----|---------|
| **TIOViewModel** (và subclass `TIOListViewModel`, …) | `cancellables` | Đã có trên base — `bindUseCase`, sink Combine trong VM → `&cancellables`. **Không** tạo `private var useCaseCancellables` / `cancellables` trùng trong subclass. |
| **TIOViewController** | `cancelBag` | Bind `trackLoading` / `trackError` / `trackSuccess` từ VM → VC. **Không** duplicate trên VM. |
| **Coordinator** | `cancelBag` (base) | Navigation / tab — không `Set<AnyCancellable>` riêng trong subclass coordinator. |

```swift
// ✅ HomeViewModel — dùng inherited cancellables
bindUseCase(..., storeIn: &cancellables, onSuccess: { ... })

// ❌ Không cần
private var useCaseCancellables = Set<AnyCancellable>()
```

- Always `[weak self]` in sinks that capture `self` / coordinator.

### Empty state

- `isListLoading == true` → show loading copy (e.g. `"Loading..."`), not “No more data”.
- `emptyDataSetShouldDisplay`: loading OR `viewModel.isEmpty()`.

### Content layout

- List screens: `containerView` (`TIOContentView`) pinned in subclass `viewDidLoad` — **không** shimmer `containerView`.
- Nib screens: `layoutIFSContentViewsIfNeeded()` pins all `IFSContentView` subviews.

## SnapKit (required for constraints)

**All programmatic layout in AppBase uses [SnapKit](https://github.com/SnapKit/SnapKit).** Do not add `NSLayoutConstraint`, `anchor`, or `translatesAutoresizingMaskIntoConstraints` unless the user explicitly requests UIKit anchors.

### Setup

```swift
import SnapKit

view.addSubview(child)
child.snp.makeConstraints { make in
    make.edges.equalToSuperview()
}
```

- Set `translatesAutoresizingMaskIntoConstraints = false` only when not using SnapKit on that view (SnapKit sets this automatically).
- Add subviews first, then constrain in the same method (`setupUI`, `viewDidLoad`, or a dedicated `setupLayout()`).

### API choice

| Situation | Use |
|-----------|-----|
| First layout after `addSubview` | `snp.makeConstraints` |
| Re-pin existing view (e.g. re-layout `IFSContentView`) | `snp.remakeConstraints` |
| Small constant/size change only | `snp.updateConstraints` |

### Standard patterns (match Foundation)

**Fill superview (VC root / container / list):**

```swift
view.snp.makeConstraints { make in
    make.edges.equalToSuperview()
}
// or shorthand:
$0.edges.equalToSuperview()
```

**Safe area (nav bar / home indicator):**

```swift
make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
make.leading.trailing.bottom.equalToSuperview()
```

**Stack vertically:**

```swift
titleLabel.snp.makeConstraints { make in
    make.top.equalToSuperview().offset(Spacing.s16)
    make.leading.trailing.equalToSuperview().inset(Spacing.s16)
}
button.snp.makeConstraints { make in
    make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.s12)
    make.centerX.equalToSuperview()
    make.height.equalTo(48)
}
button.layer.cornerRadius = Radius.s12
```

**Fixed size:**

```swift
make.width.height.equalTo(48)
make.height.equalTo(44)
```

### Where to put layout code

| Place | When |
|-------|------|
| `TIOViewController.layoutIFSContentViewsIfNeeded()` | Pin every `IFSContentView` to VC bounds |
| `TIOListViewController.viewDidLoad` | `containerView` → `view` |
| `TIOListViewController.configListContent` | `listView` → `containerView` |
| Subclass `setupUI()` | Screen-specific views (after `super.setupUI()`) |
| `TIOTableViewCell` / custom `UIView` | `setupViews()` + SnapKit in `init` or `layoutSubviews` once |

### Review / migrate rules

- Replace `NSLayoutConstraint.activate([...])` and anchor chains with SnapKit equivalents.
- Flag Storyboard-only screens only when user adds **new** programmatic subviews — new code still uses SnapKit for those subviews.
- Dùng `Spacing.*` cho `inset` / `offset`; `Radius.*` cho `cornerRadius` — không magic numbers.
- Do not mix SnapKit and manual constraints on the same view.

### Anti-patterns

```swift
// ❌ Avoid in AppBase
child.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([...])
child.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

// ✅ Use instead
child.snp.makeConstraints { make in
    make.edges.equalToSuperview()
}
```

## Optimization workflow

Copy and track:

```
- [ ] Read Foundation + ListView extensions
- [ ] Check delegate/dataSource ownership
- [ ] Verify pagination subjects + hasReachedEnd
- [ ] Verify refresh/footer end states on all paths
- [ ] Remove dead overrides (empty lifecycle, duplicate numberOfRows)
- [ ] Wire `registerNibs()` or `registerCellClasses()`; dequeue cell in `cellForRowAt`
- [ ] List loading: `startLoading`/`stopLoading` + `applyListShimmer` in cell — not shimmer `listView`
- [ ] No debug titles / placeholder strings in base classes
- [ ] Layout uses SnapKit (`import SnapKit`, `snp.makeConstraints` / `remakeConstraints`)
- [ ] No raw `NSLayoutConstraint` / anchor APIs on new or touched code
- [ ] Typography: `Font` / `FontSize` — no `UIFont.systemFont` / `.font(.system(...))` in AppBase code
- [ ] List cell: `TIOTableViewCell` / `TIOCollectionViewCell`; `cellHeight(for:)` / `cellSize(data:)` — không height magic trong VC
- [ ] Custom UIView: subclass TIO* (`TIOView`, `TIOContentView`, …) — `super.commonInit` / `applyTheme`; không `startTheming()` duplicate
- [ ] Theme: TIO* views or `bindTheme`; no `.systemBackground` / `.white` / `.label` for main UI
- [ ] Spacing / Radius: no raw `12`, `16`, `20` for padding or corner radius
- [ ] New screen: `refreshLocalization()` if có `title` / copy
- [ ] Navigation: Coordinator + `navigate(to:)`; VC/VM chỉ emit action
- [ ] Coordinator: dùng `&cancelBag` base, không duplicate
- [ ] Push màn con: bind navigation subject của màn con trong coordinator
```

### Review output format

```markdown
## Summary
[1–2 sentences]

## Critical
- [must fix]

## Suggestions
- [should improve]

## Nice to have
- [optional]
```

Severity: **Critical** = broken behavior / leaks / wrong delegate; **Suggestion** = clarity, DRY; **Nice to have** = style.

## Adding a new tab / feature coordinator

1. **Coordinator** — subclass `NavigationCoordinator<VoidMeta>`:
   - `lazy rootVC`: tạo VC, VM, `sink` navigation subjects → `store(in: &cancelBag)`.
   - `start()` → `navigate(to: .set([rootVC]))`.
   - Mỗi `push`: tạo VC + VM, bind action màn con (nếu có), `invoke`, `navigate(to: .push(...))`.
   - `pop` → `navigate(to: .pop)`.

2. **ViewModel / VC** — `PassthroughSubject` cho điều hướng (`pushTestScreen`, `navigationAction`, …); **không** giữ `UINavigationController`.

3. **Main tab** — thêm case trong `MainViewController.Tab` + `makeCoordinator`; gọi `start()` cùng các tab khác trong `viewDidLoad`.

4. **Tham khảo:** `RecordCoordinator`, `LoginCoordinator`, `MainViewController`.

## Adding a new list screen

1. **ViewModel** — subclass `TIOListViewModel`:
   - Override `numOfItemsInSection`, `refreshAndGetListData`, `loadMoreData`.
   - On full replace: `dataDidChange.send()` on main queue.
   - On append: `dataDidInsert.send((start: items.count - n, count: n))`.
   - Override `hasReachedEnd()` when API has a last page (`DataPage.canLoadMore` / `hasMorePage()` — skill **appbase-network**).

2. **ViewController** — subclass `TIOTableViewController<YourViewModel>`:
   - Cell subclass `TIOTableViewCell`; `registerCellClasses()` / `registerNibs()`.
   - `cellForRowAt`: `dequeueListCell` + `configure`; shimmer qua helper/base.
   - `heightForRowAt` → `YourCell.cellHeight(for: viewModel.item(at:))` (skeleton: `cellHeight(for: nil)`).
   - Override `tableView(_:cellForRowAt:)` — row count từ `displayItemCount` (base).
   - UI-only code sau `super.viewDidLoad()`; SnapKit trong `setupUI()`.

3. **Do not** override empty `viewWillAppear` / `setupUI` in base classes.
4. **Theme** — `TIOTableViewCell` / custom cell subclass; không hardcode `cell.backgroundColor`.

## Adding a new collection screen

1. **ViewModel** — same as table (`TIOListViewModel` + `dataDidChange` / `dataDidInsert` / `hasReachedEnd`).
2. **ViewController** — subclass `TIOCollectionViewController<YourViewModel>`:
   - Cell subclass `TIOCollectionViewCell`; `registerCells()` → `[YourCell.self]`.
   - Override `cellSize(data:)` trên cell cho dynamic size (base gọi trong `sizeForItemAt`).
   - Override `collectionView(_:cellForItemAt:)` + `applyListShimmer`.
   - Optional: `createCollectionViewLayout()`; nhiều cell type → override `sizeForItemAt` gọi đúng `CellType.cellSize`.
3. **Theme** — `TIOCollectionViewCell`; list `backgroundColor(forEmptyDataSet:)` → `palette.backgroundSecondary`.

## Common fixes

| Symptom | Likely cause | Fix |
|---------|----------------|-----|
| Row tap ignored | `listView.delegate` overwritten | Remove; keep table delegate on table VC |
| Footer spins forever | Wrong `hasReachedEnd` or missing `endLoadMore` | Fix VM + call `updatePaginationFooter` pattern |
| Crash on insert | Bad index paths / empty table | `IndexPath(row:)`; `notifyInsertItems` reloads if no sections |
| Empty state wrong | Inverted loading vs empty copy | Guard `isListLoading` in EmptyDataSet source |
| Cells not registered | `registerNibs()` empty | `registerCellClasses()` + dequeue |
| Shimmer lệch trái trong cell | `setTemplateWithSubviews` trên cả cell | `applyListShimmer` → `shimmerHost` trong `TIOTableViewCell` |
| Cả listView shimmer | `shimmerViews` trả về listView | List: `shimmerViews` = `[]`, shimmer từng cell |
| Không thấy skeleton khi load | `items` rỗng, không `startLoading` | `startLoading()` trước fetch; `displayItemCount` khi `isListCellLoading` |
| Layout warnings / broken UI | Anchor/NSLayoutConstraint mix | Migrate to SnapKit; use `remakeConstraints` when re-parenting |
| Theme không đổi khi switch dark/light | Hardcode màu / không TIO* / không `bindTheme` | Dùng TIO views + `TIOViewController`; custom view → `bindTheme` |
| Nav/tab title không đổi ngôn ngữ | Chỉ set `title` trong `viewDidLoad` | Override `refreshLocalization()` + `L10n` |
| Push/pop từ VC, coordinator không biết | `navigationController?.push` trong feature VC | Subject → coordinator `navigate(to:)` |
| Memory / duplicate subscription | `cancelBag` riêng trên coordinator subclass | Dùng `Coordinator.cancelBag` |
| Đổi tab chậm lần đầu | Lazy `loadTab` trong `shouldSelect` | Eager 5 coordinator trong `viewDidLoad` (trade-off: mở Main nặng hơn) |

## User-facing text

All labels, titles, buttons, alerts → skill **`appbase-localization`**: add to `Localizable.strings`, run SwiftGen, use `L10n`. Do not hardcode strings in VCs/cells.

Typography → **`Font`** + **`FontSize`** (section above); không hardcode `UIFont` / SwiftUI system font.

## Files to consult

- Architecture overview: `ARCHITECTURE.md` (repo root)
- Network / UseCase / APIService: `.cursor/skills/appbase-network/SKILL.md`
- Ads: `.cursor/skills/appbase-ads/SKILL.md`
- Localization: `.cursor/skills/appbase-localization/SKILL.md`
- Detailed checklist: [checklist.md](checklist.md)
- Layout tokens: `AppBase/Core/Layout/Spacing.swift`, `Radius.swift`
- Typography: `AppBase/Core/Font/`
- Foundation: `AppBase/Presentation/Foundation/`
- Coordinator: `AppBase/ThirdParty/Coordinator/`, `RecordCoordinator`, `LoginCoordinator`, `MainViewController`
- List abstractions: `AppBase/Core/UI/ListView/TIOListView.swift`, `UITableView+ListView.swift`
- Base lifecycle: `BaseMVVM/.../BaseViewController.swift`

## Out of scope

- Do not rewrite `ThirdParty/EmptyDataSet` unless user asks.
