//
//  HomeListPage.swift
//  AppBase
//

import Foundation

/// Trang danh sách Home — `DataPage` với item `Int` (demo).
typealias HomeListPage = DataPage<Int>

extension HomeListPage {

    /// Item trang hiện tại (alias `dataList`).
    var items: [Int] { dataList }

    /// Còn trang để load more không.
    var canLoadMore: Bool { hasMorePage() }
}
