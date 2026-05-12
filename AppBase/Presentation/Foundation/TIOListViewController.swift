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
        self.title = "TIOViewCotroller"
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
        listView?.mj_footer?.refreshingBlock = {[weak self] in
            self?.viewModel.loadMoreData()
        }
        viewModel.dataDidChange.sink { [weak self] in
            guard let lv = self?.listView else {return}
            lv.reloadData()
            if lv.isRefresh {
                lv.endRefreshing()
                lv.resetNoMoreData()
            }
            if self?.viewModel.canLoadMore() ?? false {
                lv.endLoadMoreWithNoData()
            }
        }.store(in: &cancelBag)
        
        viewModel.dataDidInsert.sink { [weak self] in
            let indexPaths = ($0.start..<($0.start + $0.count))
                .map { idx in IndexPath(item: idx, section: 0) }
            self?.listView?.performBatchUpdates {
                $0.notifyInsertItems(at: indexPaths)
            } completion: {
                if $0.isLoadMore {
                    $0.endLoadMore()
                }
                if self?.viewModel.canLoadMore() ?? false {
                    $0.endLoadMoreWithNoData()
                }
                  
            }
        }.store(in: &cancelBag)
    }
    
    func showListLoading() {
        guard !isListLoading else {
            return
        }
        isListLoading = true
        listView?.reloadEmptyDataSet()
    }
    
    func hideListLoading() {
        isListLoading = false
        listView?.reloadEmptyDataSet()
    }
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        if isListLoading {
            return true
        }
        return viewModel.isEmpty()
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return .white
    }
    
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView) {
        //        listIndicator.stopAnimating()
    }
    
    func emptyDataSetWillAppear(_ scrollView: UIScrollView) {
        if isListLoading {
            //            listIndicator.startAnimating()
        }
    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        if isListLoading {
            return nil
        }
        return nil
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -44.0
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return nil
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        guard isListLoading else {
            return nil
        }
        return NSAttributedString(string: "No more data")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        guard isListLoading else {
            return nil
        }
        return nil
    }
    
    func createListView() -> TIOListView {
        fatalError("list view must be created")
    }
    private func configListContent() {
        guard let lv = listView else {
            return
        }
        containerView.addSubview(lv)
        lv.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        lv.emptyDataSetSource = self
        lv.emptyDataSetDelegate = self
        lv.delegate = self
    }
}
