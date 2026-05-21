//
//  BankRepository.swift
//  AppBase
//

import Combine
import Foundation

final class BankRepository: BankRepositoryProtocol {

    private let api: APIServiceProtocol

    init(api: APIServiceProtocol = APIService.shared) {
        self.api = api
    }

    func getBanks() -> AnyPublisher<[Bank], APIError> {
        UseCasePublisher.make { completion in
            self.api.get(.vietQRBanks) { (result: Result<BaseResponse<[Bank]>, APIError>) in
                completion(result.flatMap { $0.unwrap() })
            }
        }
    }
}
