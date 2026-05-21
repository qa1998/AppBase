//
//  DataPage.swift
//  AppBase
//

import Foundation

/// Payload phân trang trong `BaseResponse.data`: `{ pages, pageSize, total, list }`.
struct DataPage<T: Codable>: Codable {

    var page: Int = 0
    var limit: Int = 0
    var total: Int = 0
    var dataList: [T] = []

    init() {}

    init(page: Int, limit: Int, total: Int, dataList: [T]) {
        self.page = page
        self.limit = limit
        self.total = total
        self.dataList = dataList
    }

    enum CodingKeys: String, CodingKey {
        case page = "pages"
        case limit = "pageSize"
        case total
        case dataList = "list"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        page = (try? container.decodeIfPresent(Int.self, forKey: .page)) ?? 0
        limit = (try? container.decodeIfPresent(Int.self, forKey: .limit)) ?? 0
        total = (try? container.decodeIfPresent(Int.self, forKey: .total)) ?? 0
        dataList = (try? container.decodeIfPresent([T].self, forKey: .dataList)) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(page, forKey: .page)
        try container.encode(limit, forKey: .limit)
        try container.encode(total, forKey: .total)
        try container.encode(dataList, forKey: .dataList)
    }

    func hasMorePage() -> Bool {
        page * limit < total
    }

    func hasMorePage(_ page: Int) -> Bool {
        page * limit < total
    }
}

extension DataPage: Equatable where T: Equatable {}
