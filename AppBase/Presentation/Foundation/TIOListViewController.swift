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

    private var isListLoading: Bool = false

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
        listView?.reloadData()
        applyShimmerToVisibleListCells(track.isLoading)
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

    func showListLoading() {
        guard !isListLoading else { return }
        isListLoading = true
        listView?.reloadEmptyDataSet()
    }

    func hideListLoading() {
        isListLoading = false
        listView?.reloadEmptyDataSet()
    }

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        if viewModel.isListCellLoading {
            return false
        }
        if isListLoading {
            return true
        }
        return viewModel.isEmpty()
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return .white
    }

    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        return nil
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -44.0
    }

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return nil
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        guard isListLoading else { return nil }
        return NSAttributedString(string: L10n.Common.loading)
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return nil
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

    func applyListCellShimmerIfNeeded(_ cell: UIView) {
        guard let shimmerCell = cell as? TIOListCellShimmerApplicable else { return }
        shimmerCell.applyListShimmer(viewModel.isListCellLoading)
    }

    private func applyShimmerToVisibleListCells(_ isLoading: Bool) {
        if let tableView = listView as? UITableView {
            tableView.visibleCells.forEach { applyListCellShimmerIfNeeded($0) }
            return
        }
        if let collectionView = listView as? UICollectionView {
            collectionView.visibleCells.forEach { applyListCellShimmerIfNeeded($0) }
        }
    }
}
