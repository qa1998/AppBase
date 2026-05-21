//
//  HomeFakeRepository.swift
//  AppBase
//

import Combine
import Foundation

final class HomeFakeRepository: HomeRepositoryProtocol {

    var simulateFailure = false

    private let requestDelay: TimeInterval = 1.5
    private let pageSize = 20
    private let totalItems = 60

    func getList(page: Int) -> AnyPublisher<HomeListPage, APIError> {
        UseCasePublisher.make { [weak self] completion in
            guard let self else { return }
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + self.requestDelay) {
                if self.simulateFailure {
                    completion(.failure(.network(NSError(domain: "fake", code: -1))))
                    return
                }
                guard page >= 1, page * self.pageSize <= self.totalItems else {
                    completion(.success(HomeListPage(
                        page: page,
                        limit: self.pageSize,
                        total: self.totalItems,
                        dataList: []
                    )))
                    return
                }
                let items = Array(repeating: page, count: self.pageSize)
                completion(.success(HomeListPage(
                    page: page,
                    limit: self.pageSize,
                    total: self.totalItems,
                    dataList: items
                )))
            }
        }
    }
}
