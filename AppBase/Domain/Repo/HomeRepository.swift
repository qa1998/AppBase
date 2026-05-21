//
//  HomeRepository.swift
//  AppBase
//

import Combine
import Foundation

final class HomeRepository: HomeRepositoryProtocol {

    private let api: APIServiceProtocol

    init(api: APIServiceProtocol = APIService.shared) {
        self.api = api
    }

    func getList(page: Int) -> AnyPublisher<HomeListPage, APIError> {
        UseCasePublisher.make { completion in
            self.api.get(.homeItems(page: page)) { (result: Result<BaseResponse<HomeListPage>, APIError>) in
                completion(result.flatMap { $0.unwrap() })
            }
        }
    }
}
