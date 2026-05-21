//
//  HomeRepositoryProtocol.swift
//  AppBase
//

import Combine
import Foundation

/// Repo — data source (API / fake). Inject qua `RepoFactory`.
protocol HomeRepositoryProtocol: AnyObject {

    func getList(page: Int) -> AnyPublisher<HomeListPage, APIError>
}
