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

class TIOListViewController<VM: TIOListViewModel>: TIOViewController<VM>,
                                                   UIScrollViewDelegate,
                                                   EmptyDataSetSource,
                                                   EmptyDataSetDelegate {

    private var listView: TIOListView?

    private var isListLoading: Bool = false

    lazy var containerView: TIOContentView = {
        let container = TIOContentView()
        return container
    }()

    init(nibName: String? = nil) {
        super.init(nibName: nibName, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
            if self.viewModel.canLoadMore() {
                lv.resetNoMoreData()
            } else {
                lv.endLoadMoreWithNoData()
            }
        }.store(in: &cancelBag)

        viewModel.dataDidInsert.sink { [weak self] in
            let indexPaths = ($0.start..<($0.start + $0.count))
                .map { idx in IndexPath(item: idx, section: 0) }
            self?.listView?.performBatchUpdates {
                $0.notifyInsertItems(at: indexPaths)
            } completion: { [weak self] list in
                guard let self else { return }
                if list.isLoadMore {
                    list.endLoadMore()
                }
                if self.viewModel.canLoadMore() {
                    list.resetNoMoreData()
                } else {
                    list.endLoadMoreWithNoData()
                }
            }
        }.store(in: &cancelBag)
    }

    // MARK: - List loading (empty state “loading”)

    func showListLoading() {
        guard !isListLoading else { return }
        isListLoading = true
        listView?.reloadEmptyDataSet()
    }

    func hideListLoading() {
        guard isListLoading else { return }
        isListLoading = false
        listView?.reloadEmptyDataSet()
    }

    // MARK: - EmptyDataSet — override in subclass (strings / image)

    /// Tiêu đề khi không có dữ liệu (không phải trạng thái loading).
    open func listEmptyTitleString() -> String {
        "Không có dữ liệu"
    }

    open func listEmptyDescriptionString() -> String? {
        nil
    }

    open func listEmptyImage() -> UIImage? {
        UIImage(systemName: "tray")
    }

    open func listEmptyImageTintColor() -> UIColor? {
        .tertiaryLabel
    }

    open func listEmptyVerticalOffset() -> CGFloat {
        -44
    }

    /// Nền vùng empty (nil = trong suốt).
    open func listEmptyBackgroundColor() -> UIColor? {
        nil
    }

    /// Custom view thay thế toàn bộ empty (không loading). Mặc định nil → dùng title/description/image.
    open func listEmptyCustomView(for scrollView: UIScrollView) -> UIView? {
        nil
    }

    open func listLoadingDescriptionString() -> String {
        "Đang tải..."
    }

    // MARK: - EmptyDataSetSource

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        if isListLoading { return true }
        return viewModel.isEmpty()
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        listEmptyBackgroundColor()
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        listEmptyVerticalOffset()
    }

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        guard !isListLoading else { return nil }
        let title = listEmptyTitleString()
        return NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
        )
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if isListLoading {
            return NSAttributedString(
                string: listLoadingDescriptionString(),
                attributes: [
                    .font: UIFont.systemFont(ofSize: 15, weight: .regular),
                    .foregroundColor: UIColor.secondaryLabel
                ]
            )
        }
        guard let desc = listEmptyDescriptionString(), !desc.isEmpty else { return nil }
        return NSAttributedString(
            string: desc,
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .regular),
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        guard !isListLoading else { return nil }
        return listEmptyImage()
    }

    func imageTintColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        guard !isListLoading else { return nil }
        return listEmptyImageTintColor()
    }

    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        if isListLoading {
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.startAnimating()
            return indicator
        }
        return listEmptyCustomView(for: scrollView)
    }

    func emptyDataSetWillDisappear(_ scrollView: UIScrollView) {}

    func emptyDataSetWillAppear(_ scrollView: UIScrollView) {}

    // MARK: - Factory

    func createListView() -> TIOListView {
        fatalError("list view must be created")
    }

    private func configListContent() {
        guard let lv = listView else { return }
        containerView.addSubview(lv)
        lv.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        lv.emptyDataSetSource = self
        lv.emptyDataSetDelegate = self
        lv.delegate = self
    }
}
