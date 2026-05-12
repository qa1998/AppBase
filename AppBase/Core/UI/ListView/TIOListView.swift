//
//  TIOListView.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
import TIOPagingKit
import MJRefresh
import Combine

internal protocol TIOListView where Self: UIScrollView {
    var isRefresh: Bool { get }
    var isLoadMore: Bool {get}
    func reloadData()
    func performBatchUpdates(_ update: ((TIOListView) -> Void)?, completion: ((TIOListView) -> Void)?)
    func notifyInsertItems(at indexPaths: [IndexPath])
    func notiDeleteItems(at indexPaths: [IndexPath])
    
    func beginRefreshing()
    func endRefreshing()
    
    func beginLoadMore()
    func endLoadMore()
    func endLoadMoreWithNoData()
    func resetNoMoreData()
    
}

extension TIOListView {
    
    var isRefresh: Bool {
        return self.mj_header?.isRefreshing ?? false
    }
    
    var isLoadMore: Bool {
        return self.mj_footer?.isRefreshing ?? false
    }
    
    func beginRefreshing() {
        self.mj_header?.beginRefreshing()
    }
    
    func endRefreshing() {
        self.mj_header?.endRefreshing()
    }
    
    func beginLoadMore() {
        self.mj_footer?.beginRefreshing()
    }
    func endLoadMore() {
        self.mj_footer?.endRefreshing()
    }
    
    func endLoadMoreWithNoData() {
        mj_footer?.endRefreshingWithNoMoreData()
    }
    func resetNoMoreData() {
        mj_footer?.resetNoMoreData()
    }
}
