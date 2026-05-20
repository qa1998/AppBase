//
//  TIOListViewModel.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
import BaseMVVM
import Combine

class TIOListViewModel: TIOViewModel<TIOLoadingTarget> {

    let dataDidChange = PassthroughSubject<Void, Never>()
    let dataDidInsert = PassthroughSubject<(start: Int, count: Int), Never>()

    private(set) var isListCellLoading = false

    /// Số skeleton cell khi đang load (shimmer trong cell).
    var skeletonPlaceholderCount: Int { 8 }

    func numberOfSections() -> Int {
        return 1
    }

    func numOfItemsInSection(_ section: Int) -> Int {
        return 0
    }

    /// Số item hiển thị trên list (skeleton khi `isListCellLoading`).
    func displayItemCount(in section: Int) -> Int {
        if isListCellLoading {
            return skeletonPlaceholderCount
        }
        return numOfItemsInSection(section)
    }

    func setListCellLoading(_ loading: Bool) {
        isListCellLoading = loading
    }

    func item(at indexPath: IndexPath) -> Any? {
        return nil
    }

    func didSelectItem(at: IndexPath) {

    }

    func refreshAndGetListData() {

    }

    func loadMoreData() {

    }

    /// `true` when there is no next page (footer should show "no more data").
    func hasReachedEnd() -> Bool {
        return false
    }

    func isEmpty() -> Bool {
        var total: Int = 0
        for section in 0..<numberOfSections() {
            total += numOfItemsInSection(section)
        }
        return total == 0
    }
}
