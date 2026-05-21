//
//  HomeServiceImpl.swift
//  AppBase
//

import Combine
import Foundation

final class HomeServiceImpl: HomeServiceProtocol {

    private let repository: HomeRepositoryProtocol

    init(repository: HomeRepositoryProtocol) {
        self.repository = repository
    }

    func getHomeList(page: Int) -> AnyPublisher<HomeListPage, APIError> {
        repository.getList(page: page)
    }
}
