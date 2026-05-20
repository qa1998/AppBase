//
//  HomeViewModel.swift
//  AppBase
//
//  Created by Quang Anh Le on 11/5/26.
//

import BaseMVVM
import Foundation
import Combine

class HomeViewModel: TIOListViewModel {

    private let fakeAPI = HomeFakeAPI.shared

    private(set) var items: [Int] = []
    private(set) var page: Int = 0

    override func numOfItemsInSection(_ section: Int) -> Int {
        return items.count
    }

    override func viewModelDidReady() {
        super.viewModelDidReady()
        loadInitialData()
    }

    func loadInitialData() {
        page = 0
        items = []
        fetchPage(1, isRefresh: false)
    }

    override func refreshAndGetListData() {
        fetchPage(1, isRefresh: true)
    }

    override func loadMoreData() {
        guard fakeAPI.hasMorePages(after: page) else { return }
        fetchPage(page + 1, isRefresh: false, isLoadMore: true)
    }

    override func hasReachedEnd() -> Bool {
        !fakeAPI.hasMorePages(after: page)
    }

    // MARK: - Private

    private func fetchPage(_ page: Int, isRefresh: Bool, isLoadMore: Bool = false) {
        if isRefresh || !isLoadMore {
            startLoading()
        }

        fakeAPI.fetchItems(page: page) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                if isRefresh || !isLoadMore {
                    self.stopLoading()
                }

                switch result {
                case .success(let response):
                    self.apply(response: response, isLoadMore: isLoadMore)
                case .failure:
                    if isLoadMore {
                        return
                    }
                    self.page = 0
                    self.items = []
                    self.dataDidChange.send()
                }
            }
        }
    }

    private func apply(response: HomeListResponse, isLoadMore: Bool) {
        page = response.page

        if isLoadMore {
            let startIndex = items.count
            items.append(contentsOf: response.items)
            dataDidInsert.send((start: startIndex, count: response.items.count))
        } else {
            items = response.items
            dataDidChange.send()
        }
    }
}
