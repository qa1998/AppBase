# AppBase iOS — Deep review checklist

Use with [SKILL.md](SKILL.md) when doing a thorough review or pre-PR pass.

## SnapKit layout

- [ ] `import SnapKit` in files with programmatic layout
- [ ] Constraints via `snp.makeConstraints` / `remakeConstraints` / `updateConstraints` only
- [ ] No new `NSLayoutConstraint.activate`, `anchor`, or `isActive = true` on touched code
- [ ] Subviews added before constraints; layout in `setupUI` or `viewDidLoad` as appropriate
- [ ] Full-bleed children use `make.edges.equalToSuperview()` (or safe-area variants)
- [ ] Re-layout uses `remakeConstraints`, not duplicate `makeConstraints` on same view

## TIOViewController

- [ ] No empty lifecycle overrides (`viewWillAppear` …) unless adding behavior
- [ ] `cancelBag` only here for VC-side Combine
- [ ] `layoutIFSContentViewsIfNeeded()` uses all `IFSContentView` subviews, not `first(where:)`
- [ ] `layoutIFSContentViewsIfNeeded()` pins with `snp.remakeConstraints { make.edges.equalToSuperview() }`
- [ ] `onBackPress` appropriate for navigation stack vs modal

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
- [ ] `registerNibs()` implemented in subclass when using `TIOTableViewCell`
- [ ] `cellForRowAt` overridden in every concrete table VC
- [ ] No redundant `numberOfRowsInSection` override unless custom section logic

## TIOCollectionViewController

- [ ] `collectionView.delegate` and `dataSource` remain `self` on collection VC
- [ ] Never set `listView.delegate` on list base (same as table)
- [ ] `registerCells()` implemented when using `TIOCollectionViewCell`
- [ ] `cellForItemAt` overridden in every concrete collection VC
- [ ] `createCollectionViewLayout()` overridden if not using default flow layout
- [ ] Pagination inserts use `IndexPath(item:)` via `makeListIndexPath`

## TIOListViewModel

- [ ] `hasReachedEnd()` semantics documented in subclass
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

- [ ] Avoid `reloadData()` when batch insert/delete is possible
- [ ] Cell reuse via registered nibs/classes
- [ ] Custom cells: SnapKit in `init`, not repeated work in `layoutSubviews` every pass
- [ ] Images/async work not blocking main in `cellForRowAt`

## Security & data

- [ ] No secrets in VC/VM
- [ ] User-facing errors surfaced intentionally (not silent empty lists)
