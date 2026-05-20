//
//  HomeFakeAPI.swift
//  AppBase
//

import Foundation

struct HomeListResponse {
    let page: Int
    let items: [Int]
}

enum HomeFakeAPIError: Error {
    case simulatedFailure
}

/// API giả — delay 1.5s, tối đa 3 trang, mỗi trang 20 item.
final class HomeFakeAPI {

    static let shared = HomeFakeAPI()

    private let requestDelay: TimeInterval = 1.5
    private let pageSize = 20
    private let maxPage = 3

    private init() {}

    func fetchItems(
        page: Int,
        simulateFailure: Bool = false,
        completion: @escaping (Result<HomeListResponse, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + requestDelay) {
            if simulateFailure {
                completion(.failure(HomeFakeAPIError.simulatedFailure))
                return
            }
            guard page >= 1, page <= self.maxPage else {
                completion(.success(HomeListResponse(page: page, items: [])))
                return
            }
            let items = Array(repeating: page, count: self.pageSize)
            completion(.success(HomeListResponse(page: page, items: items)))
        }
    }

    func hasMorePages(after page: Int) -> Bool {
        page < maxPage
    }
}
