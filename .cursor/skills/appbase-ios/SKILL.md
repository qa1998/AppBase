---
name: appbase-ios
description: >-
  Reviews and optimizes AppBase iOS presentation code (TIOViewController,
  TIOListViewController, TIOTableViewController, TIOListViewModel, TIOListView).
  Enforces SnapKit for all programmatic Auto Layout. Use when the user asks to
  review, refactor, optimize, add UI/layout, constraints, or list/screen features
  in AppBase, or mentions TIO, SnapKit, snp, BaseMVVM, MJRefresh, EmptyDataSet,
  TIOPagingKit, TrackLoading, shimmer, skeleton loading, UIView-Shimmer, Font,
  FontSize, or Lato typography. For UI text and copy, use skill `appbase-localization`
  (L10n + SwiftGen) — never hardcode user-facing strings.
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

- VC bindings → `cancelBag` on `TIOViewController` only (not duplicated on `TIOViewModel`).
- Always `[weak self]` in sinks that capture `self`.

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
    make.top.equalToSuperview().offset(16)
    make.leading.trailing.equalToSuperview().inset(16)
}
button.snp.makeConstraints { make in
    make.top.equalTo(titleLabel.snp.bottom).offset(12)
    make.centerX.equalToSuperview()
    make.height.equalTo(44)
}
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
- Prefer `inset` / `offset` over magic numbers; group related spacing in one place when a screen has many constraints.
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

## Adding a new collection screen

1. **ViewModel** — same as table (`TIOListViewModel` + `dataDidChange` / `dataDidInsert` / `hasReachedEnd`).
2. **ViewController** — subclass `TIOCollectionViewController<YourViewModel>`:
   - Override `registerCells()` → `[YourCell.self]`.
   - Override `collectionView(_:cellForItemAt:)`.
   - Optional: `createCollectionViewLayout()`, `sizeForItemAt`, `registerCells(_, useNib: true)` for nib cells.

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

## User-facing text

All labels, titles, buttons, alerts → skill **`appbase-localization`**: add to `Localizable.strings`, run SwiftGen, use `L10n`. Do not hardcode strings in VCs/cells.

Typography → **`Font`** + **`FontSize`** (section above); không hardcode `UIFont` / SwiftUI system font.

## Files to consult

- Localization: `.cursor/skills/appbase-localization/SKILL.md`
- Detailed checklist: [checklist.md](checklist.md)
- Typography: `AppBase/Core/Font/`
- Foundation: `AppBase/Presentation/Foundation/`
- List abstractions: `AppBase/Core/UI/ListView/TIOListView.swift`, `UITableView+ListView.swift`
- Base lifecycle: `BaseMVVM/.../BaseViewController.swift`

## Out of scope

- Do not rewrite `ThirdParty/EmptyDataSet` unless user asks.
