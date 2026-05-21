//
//  HomeServiceProtocol.swift
//  AppBase
//

import Combine
import Foundation

/// Service — business entry cho Home. UseCase gọi Service, không gọi Repo trực tiếp.
protocol HomeServiceProtocol: AnyObject {

    func getHomeList(page: Int) -> AnyPublisher<HomeListPage, APIError>
}
