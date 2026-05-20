---
name: appbase-ios
description: >-
  Reviews and optimizes AppBase iOS presentation code (TIOViewController,
  TIOListViewController, TIOTableViewController, TIOListViewModel, TIOListView).
  Enforces SnapKit for all programmatic Auto Layout. Use when the user asks to
  review, refactor, optimize, add UI/layout, constraints, or list/screen features
  in AppBase, or mentions TIO, SnapKit, snp, BaseMVVM, MJRefresh, EmptyDataSet,
  TIOPagingKit, TrackLoading, shimmer, skeleton loading, UIView-Shimmer, Font,
  FontSize, Lato typography, Spacing, Radius, ThemeManager, TIOThemable, palette, or dark/light mode,
  Coordinator, NavigationCoordinator, cancelBag, lazy tab, push/pop navigation.
  For UI text and copy, use skill `appbase-localization` (L10n + SwiftGen) — never
  hardcode user-facing strings. **Every new view/screen must apply theme** (see below).
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
| **ViewModel** | Data, `dataDidChange` / `dataDidInsert`, `hasReachedEnd()`, API calls |
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
- [ ] Custom UIView: bindTheme { } hoặc subclass TIOView + applyTheme
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
    let trackLoading = PassthroughSubject<TrackLoading<Event>, Never>()
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

**Cell registration:**

- Programmatic: `override func registerCellClasses() -> [TIOTableViewCell.Type] { [MyCell.self] }`
- Nib: `registerNibs() -> [MyCell.self]`
- **Dequeue** bắt buộc — không `TIOTableViewCell()` tay
- Row height cố định khi skeleton (vd. `72`) tránh layout nhảy

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

### Fake API (test)

Tách `*FakeAPI` (delay ~1.5s), gọi từ ViewModel:

```swift
final class HomeFakeAPI {
    static let shared = HomeFakeAPI()
    func fetchItems(page: Int, completion: @escaping (Result<HomeListResponse, Error>) -> Void)
}
```

Files: `TrackLoading.swift`, `TIOViewModel.swift`, `TIOViewController.swift`, `TIOListViewModel.swift`, `TIOListViewController.swift`, `TIOListCell+Shimmer.swift`, `TIOTableViewCell.swift`, `TIOCollectionViewCell.swift`.

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

- **VC** bindings → `cancelBag` trên `TIOViewController` only (not duplicated on `TIOViewModel`).
- **Coordinator** bindings → `cancelBag` trên `Coordinator` base (không tạo `Set<AnyCancellable>` riêng trong subclass).
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
   - Override `hasReachedEnd()` when API has a last page (use `maxPage`, not magic numbers inline).

2. **ViewController** — subclass `TIOTableViewController<YourViewModel>`:
   - `registerCellClasses()` hoặc `registerNibs()`; dequeue trong `cellForRowAt`.
   - `applyListShimmer(true/false)` theo `viewModel.isListCellLoading`.
   - `heightForRowAt` cố định nếu cần skeleton đẹp (vd. 72).
   - Override `tableView(_:cellForRowAt:)` — row count từ `displayItemCount` (base).
   - UI-only code sau `super.viewDidLoad()`; SnapKit trong `setupUI()`.

3. **Do not** override empty `viewWillAppear` / `setupUI` in base classes.
4. **Theme** — `TIOTableViewCell` / custom cell subclass; không hardcode `cell.backgroundColor`.

## Adding a new collection screen

1. **ViewModel** — same as table (`TIOListViewModel` + `dataDidChange` / `dataDidInsert` / `hasReachedEnd`).
2. **ViewController** — subclass `TIOCollectionViewController<YourViewModel>`:
   - Override `registerCells()` → `[YourCell.self]`.
   - Override `collectionView(_:cellForItemAt:)`.
   - Optional: `createCollectionViewLayout()`, `sizeForItemAt`, `registerCells(_, useNib: true)` for nib cells.
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
