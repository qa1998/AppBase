//
//  TIOListViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
import BaseMVVM
import SnapKit
import Combine
import MJRefresh

class TIOListViewController<VM: TIOListViewModel>: TIOScreenViewController<VM>,
                                                   EmptyDataSetSource,
                                                   EmptyDataSetDelegate {

    private var listView: TIOListView?

    lazy var containerView: TIOContentView = {
        TIOContentView()
    }()

    /// List không shimmer `listView` — chỉ shimmer trong cell (override `handleTrackLoading`).
    override func shimmerViews(for event: TIOLoadingTarget) -> [UIView] {
        []
    }

    override func handleTrackLoading(_ track: TrackLoading<TIOLoadingTarget>) {
        guard case .screen = track.event else { return }
        viewModel.setListCellLoading(track.isLoading)
        // Skeleton qua `displayItemCount` + `cellForRowAt` → `applyListShimmer` (không shimmer 2 lần).
        listView?.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        layoutIFSContentViewsIfNeeded()
    }

    override func setupUI() {
        super.setupUI()
        listView = createListView()
        configListContent()
    }

    override func onBind() {
        super.onBind()
        listView?.mj_header?.refreshingBlock = { [weak self] in
            self?.viewModel.refreshAndGetListData()
        }
        listView?.mj_footer?.refreshingBlock = { [weak self] in
            self?.viewModel.loadMoreData()
        }
        viewModel.dataDidChange.sink { [weak self] in
            guard let self, let lv = self.listView else { return }
            lv.reloadData()
            lv.reloadEmptyDataSet()
            if lv.isRefresh {
                lv.endRefreshing()
                lv.resetNoMoreData()
            }
            if lv.isLoadMore {
                lv.endLoadMore()
            }
            self.updatePaginationFooter(for: lv)
        }.store(in: &cancelBag)

        viewModel.dataDidInsert.sink { [weak self] payload in
            guard let self else { return }
            let indexPaths = (payload.start..<(payload.start + payload.count))
                .map { self.makeListIndexPath(item: $0, section: 0) }
            self.listView?.performBatchUpdates { listView in
                listView.notifyInsertItems(at: indexPaths)
            } completion: { [weak self] listView in
                guard let self else { return }
                if listView.isLoadMore {
                    listView.endLoadMore()
                }
                self.updatePaginationFooter(for: listView)
            }
        }.store(in: &cancelBag)
    }

    @available(*, deprecated, message: "Dùng skeleton cell: startLoading() / stopLoading() trên ViewModel.")
    func showListLoading() {
        listView?.reloadEmptyDataSet()
    }

    @available(*, deprecated, message: "Dùng skeleton cell: startLoading() / stopLoading() trên ViewModel.")
    func hideListLoading() {
        listView?.reloadEmptyDataSet()
    }

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        if viewModel.isListCellLoading {
            return false
        }
        switch viewModel.listDisplayState {
        case .error:
            return true
        case .empty:
            return viewModel.isEmpty()
        case .content:
            return viewModel.isEmpty()
        }
    }

    /// Cho phép kéo (MJRefresh) khi empty / error — mặc định EmptyDataSet tắt scroll.
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        if viewModel.isListCellLoading {
            return false
        }
        switch viewModel.listDisplayState {
        case .empty, .error:
            return true
        case .content:
            return viewModel.isEmpty()
        }
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        ThemeManager.shared.palette.backgroundSecondary
    }

    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        return nil
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -44.0
    }

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        switch viewModel.listDisplayState {
        case .error:
            return TIOEmptyDataSetStyle.title(L10n.List.Error.title)
        case .empty:
            return TIOEmptyDataSetStyle.title(L10n.List.Empty.title)
        case .content:
            return nil
        }
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        switch viewModel.listDisplayState {
        case .error(let message):
            return TIOEmptyDataSetStyle.description(message ?? L10n.List.Error.message)
        case .empty:
            return TIOEmptyDataSetStyle.description(L10n.List.Empty.message)
        case .content:
            return nil
        }
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        guard case .error = viewModel.listDisplayState, state == .normal else { return nil }
        return TIOEmptyDataSetStyle.buttonTitle(L10n.Common.retry)
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return nil
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
        viewModel.retryListLoad()
    }

    func createListView() -> TIOListView {
        fatalError("list view must be created")
    }

    /// `IndexPath(item:)` for collection views, `IndexPath(row:)` for table views.
    func makeListIndexPath(item index: Int, section: Int = 0) -> IndexPath {
        if listView is UICollectionView {
            return IndexPath(item: index, section: section)
        }
        return IndexPath(row: index, section: section)
    }

    private func configListContent() {
        guard let lv = listView else { return }
        lv.alwaysBounceVertical = true
        containerView.addSubview(lv)
        lv.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        lv.emptyDataSetSource = self
        lv.emptyDataSetDelegate = self
    }

    private func updatePaginationFooter(for listView: TIOListView) {
        if viewModel.hasReachedEnd() {
            listView.endLoadMoreWithNoData()
        }
    }

    /// Gọi trong `cellForRowAt` / `cellForItemAt` sau dequeue.
    func applyListCellShimmerIfNeeded(_ cell: UIView) {
        guard let shimmerCell = cell as? TIOListCellShimmerApplicable else { return }
        shimmerCell.applyListShimmer(viewModel.isListCellLoading)
    }
}
