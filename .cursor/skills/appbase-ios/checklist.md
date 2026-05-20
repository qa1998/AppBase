# AppBase iOS — Deep review checklist

Use with [SKILL.md](SKILL.md) when doing a thorough review or pre-PR pass.

## SnapKit layout

- [ ] `import SnapKit` in files with programmatic layout
- [ ] Constraints via `snp.makeConstraints` / `remakeConstraints` / `updateConstraints` only
- [ ] No new `NSLayoutConstraint.activate`, `anchor`, or `isActive = true` on touched code
- [ ] Subviews added before constraints; layout in `setupUI` or `viewDidLoad` as appropriate
- [ ] Full-bleed children use `make.edges.equalToSuperview()` (or safe-area variants)
- [ ] Re-layout uses `remakeConstraints`, not duplicate `makeConstraints` on same view
- [ ] `offset` / `inset` dùng `Spacing.*` — không magic number
- [ ] `cornerRadius` / `RoundedRectangle` dùng `Radius.*`

## Coordinator & navigation

- [ ] Feature flow có `*Coordinator` kế thừa `NavigationCoordinator<VoidMeta>`
- [ ] `push` / `pop` / `set` chỉ qua `navigate(to:)` — không `navigationController?.push` trong feature VC
- [ ] VC / VM bắn action: `PassthroughSubject` (hoặc publisher trên VC) → coordinator `sink`
- [ ] Subclass coordinator **không** tạo `private var cancelBag` — dùng `&cancelBag` trên `Coordinator` base
- [ ] `sink` navigation: `[weak self]` + `store(in: &cancelBag)`
- [ ] Màn push mới có action riêng → `bind*Navigation(viewModel)` trước `invoke` + `push`
- [ ] `Coordinator<VoidMeta>` / `NavigationCoordinator<VoidMeta>` — không bỏ generic
- [ ] Tab mới trong `MainViewController`: thêm `Tab` case + `makeCoordinator` + `start()` trong `viewDidLoad` (eager 5 tab)
- [ ] Retain coordinator trong mảng `coordinators`
- [ ] ESTabBar: `syncESTabBarHighlight` trong `viewDidAppear` / `didSelect`

## TIOViewController

- [ ] No empty lifecycle overrides (`viewWillAppear` …) unless adding behavior
- [ ] `cancelBag` only here for VC-side Combine (không trùng trên Coordinator)
- [ ] `layoutIFSContentViewsIfNeeded()` uses all `IFSContentView` subviews, not `first(where:)`
- [ ] `layoutIFSContentViewsIfNeeded()` pins with `snp.remakeConstraints { make.edges.equalToSuperview() }`
- [ ] `onBackPress` appropriate for navigation stack vs modal

## TrackLoading / shimmer

- [ ] List: **không** shimmer `tableView` / `collectionView` (`shimmerViews` → `[]`)
- [ ] List fetch/refresh: `startLoading()` → `stopLoading()` trên main sau API
- [ ] Load more: **không** `startLoading()` (chỉ footer MJRefresh)
- [ ] `cellForRowAt` / `cellForItemAt`: `applyListShimmer(viewModel.isListCellLoading)`
- [ ] Dequeue cell (`dequeueReusableCell`), không `init()` tay
- [ ] `registerCellClasses()` hoặc `registerNibs()` đã gọi trong `setupUI`
- [ ] `TIOTableViewCell` / `TIOCollectionViewCell` dùng `shimmerHost` full width (SnapKit inset)
- [ ] `emptyDataSetShouldDisplay` = false khi `isListCellLoading`
- [ ] Màn non-list: `TIOViewController<VM, Event>` + `shimmerViews(for:)` map đúng views
- [ ] Fake API tách file, delay main thread cho UI update

## Theme (bắt buộc mỗi view/screen mới)

- [ ] VC: `TIOViewController` / list base — **không** `view.backgroundColor = .systemBackground`
- [ ] Subviews: `TIOView`, `TIOLabel`, `TIOButton`, `TIOContentView` (không UIKit thuần)
- [ ] Custom `UIView`: `bindTheme { }` hoặc subclass `TIOView` + `applyTheme(_:)`
- [ ] Không `.white` / `.black` / `.label` / `.secondaryLabel` cho UI chính
- [ ] CTA: `TIOButton` + `usesFilledPrimaryStyle = true` khi nền primary
- [ ] SwiftUI: `@ObservedObject themeManager` + `themeManager.palette.*`
- [ ] Shimmer: `palette.backgroundSecondary` làm `viewBackgroundColor`
- [ ] Cell: `TIOTableViewCell` / `TIOCollectionViewCell` (đã có theme sẵn)

## Spacing & Radius

- [ ] Padding / margin / stack spacing → `Spacing.s*`
- [ ] Bo góc → `Radius.s*`
- [ ] Giá trị mới → thêm token trong `Spacing.swift` / `Radius.swift`

## Typography

- [ ] UIKit: `Font.default` / `Font.bold` / `Font.italic` + `FontSize` token
- [ ] SwiftUI: `Font.swiftUIFont(_:style:)` — không `.font(.system(...))`
- [ ] `TIOButton` / labels mới: không `UIFont.systemFont` trực tiếp
- [ ] Size lẻ: `FontSize.custom(_)` thay vì magic number trong `systemFont(ofSize:)`

## TIOView / cells

- [ ] `TIOContentView`: `shimmeringAnimatedItems` rỗng — container không shimmer
- [ ] `TIOLabel` / `TIOButton` / `TIOView` cho UI cần shimmer từng vùng
- [ ] Không `setTemplateWithSubviews` trực tiếp lên `UITableViewCell` root

## TIOListViewController

- [ ] No `lv.delegate = self`
- [ ] No hardcoded `title` or debug strings in base class
- [ ] `mj_header` / `mj_footer` use `[weak self]`
- [ ] `dataDidChange` handler: `endRefreshing`, `resetNoMoreData`, `endLoadMore` when `isLoadMore`, then `hasReachedEnd` → `endLoadMoreWithNoData`
- [ ] `dataDidInsert` handler: batch insert, `endLoadMore` when `isLoadMore`, then pagination footer
- [ ] EmptyDataSet: loading text vs empty state are distinct
- [ ] `containerView` added in `viewDidLoad` after `super` (which already ran `setupUI`)
- [ ] `containerView` and `listView` constrained with SnapKit (`edges.equalToSuperview()`)

## TIOTableViewController

- [ ] `tableView.delegate` and `dataSource` remain `self` on table VC
- [ ] `registerNibs()` / `registerCellClasses()` implemented in subclass
- [ ] `cellForRowAt` overridden; `applyListShimmer` khi loading
- [ ] Row count từ `displayItemCount` — không override trừ khi custom sections
- [ ] `heightForRowAt` ổn định khi dùng skeleton (optional nhưng khuyến nghị)

## TIOCollectionViewController

- [ ] `collectionView.delegate` and `dataSource` remain `self` on collection VC
- [ ] Never set `listView.delegate` on list base (same as table)
- [ ] `registerCells()` implemented when using `TIOCollectionViewCell`
- [ ] `cellForItemAt` overridden in every concrete collection VC
- [ ] `createCollectionViewLayout()` overridden if not using default flow layout
- [ ] Pagination inserts use `IndexPath(item:)` via `makeListIndexPath`

## TIOListViewModel

- [ ] `TIOViewModel<TIOLoadingTarget>` hoặc custom `Event` (không default generic)
- [ ] `hasReachedEnd()` semantics documented in subclass
- [ ] `setListCellLoading` chỉ qua `trackLoading` / `handleTrackLoading` trên list VC
- [ ] Network/async work dispatches UI updates on main
- [ ] `isEmpty()` consistent with section/item counts
- [ ] Selection handling in `didSelectItem(at:)` not in VC when avoidable

## TIOListView / UITableView+ListView

- [ ] `notifyInsertItems` safe for first page (reload or insert, not `reconfigureRows` on empty)
- [ ] `performBatchUpdates` completions use weak self where needed

## Home / feature screens

- [ ] ViewModel sends correct subject (`dataDidChange` vs `dataDidInsert`)
- [ ] Page index and `hasReachedEnd` use named constants (`maxPage`)
- [ ] No business logic duplicated in VC that belongs in VM

## Performance & size

- [ ] Main tab: 5 coordinator start trong `viewDidLoad` (đổi tab instant, mở Main có thể chậm hơn)
- [ ] Tab coordinator: `lazy var rootVC` — tạo khi `start()`
- [ ] List loading: không `applyShimmerToVisibleListCells` sau `reloadData` (shimmer trong `cellForRowAt`)
- [ ] Avoid `reloadData()` when batch insert/delete is possible
- [ ] Cell reuse via registered nibs/classes
- [ ] Custom cells: SnapKit in `init`, not repeated work in `layoutSubviews` every pass
- [ ] Images/async work not blocking main in `cellForRowAt`

## Security & data

- [ ] No secrets in VC/VM
- [ ] User-facing errors surfaced intentionally (not silent empty lists)
