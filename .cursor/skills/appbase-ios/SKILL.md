---
name: appbase-ios
description: >-
  Reviews and optimizes AppBase iOS presentation code (TIOViewController,
  TIOListViewController, TIOTableViewController, TIOListViewModel, TIOListView).
  Enforces SnapKit for all programmatic Auto Layout. Use when the user asks to
  review, refactor, optimize, add UI/layout, constraints, or list/screen features
  in AppBase, or mentions TIO, SnapKit, snp, BaseMVVM, MJRefresh, EmptyDataSet,
  or TIOPagingKit.
---

# AppBase iOS Presentation

## Architecture (read first)

```
BaseViewController<VM>     // viewDidLoad → setupUI → onBind → viewModelDidReady
  └── TIOViewController<VM: TIOViewModel>           // cancelBag, IFSContentView layout
        └── TIOListViewController<VM: TIOListViewModel>  // refresh/load-more, empty state
              ├── TIOTableViewController              // UITableViewDelegate/DataSource
              └── TIOCollectionViewController         // UICollectionViewDelegate/DataSource
```

| Layer | Responsibility |
|-------|----------------|
| **ViewModel** | Data, `dataDidChange` / `dataDidInsert`, `hasReachedEnd()`, API calls |
| **List VC** | Bind subjects, MJRefresh, EmptyDataSet, **never** replace table `delegate` |
| **Table VC** | `registerNibs()`, `cellForRowAt` (override required), table delegate |
| **Collection VC** | `registerCells()`, `cellForItemAt` (override required), flow layout size |

Lifecycle order matters: `BaseViewController.viewDidLoad` runs `setupUI` **before** subclass `viewDidLoad` adds `containerView`.

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

- List screens: `containerView` (`TIOContentView` / `IFSContentView`) pinned in subclass `viewDidLoad`, then `layoutIFSContentViewsIfNeeded()`.
- Nib screens: `layoutIFSContentViewsIfNeeded()` pins all `IFSContentView` subviews — avoid `first(where:)` only; use loop over all matches.

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
- [ ] Wire registerNibs in TIOTableViewController subclass if using TIOTableViewCell
- [ ] No debug titles / placeholder strings in base classes
- [ ] Layout uses SnapKit (`import SnapKit`, `snp.makeConstraints` / `remakeConstraints`)
- [ ] No raw `NSLayoutConstraint` / anchor APIs on new or touched code
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
   - Override `registerNibs()` if using `TIOTableViewCell`.
   - Override `tableView(_:cellForRowAt:)` only (row count comes from base).
   - Put UI-only code in `viewDidLoad` **after** `super.viewDidLoad()`.
   - Add extra views with SnapKit in `setupUI()` (after `super.setupUI()`).

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
| Cells not registered | `registerNibs()` empty | Return cell types; base calls `registerNibs(for:)` in `setupUI` |
| Layout warnings / broken UI | Anchor/NSLayoutConstraint mix | Migrate to SnapKit; use `remakeConstraints` when re-parenting |

## Files to consult

- Detailed checklist: [checklist.md](checklist.md)
- Foundation: `AppBase/Presentation/Foundation/`
- List abstractions: `AppBase/Core/UI/ListView/TIOListView.swift`, `UITableView+ListView.swift`
- Base lifecycle: `BaseMVVM/.../BaseViewController.swift`

## Out of scope

- Do not rewrite `ThirdParty/EmptyDataSet` unless user asks.
