//
//  BankServiceImpl.swift
//  AppBase
//

import Combine
import Foundation

final class BankServiceImpl: BankServiceProtocol {

    private let repository: BankRepositoryProtocol

    init(repository: BankRepositoryProtocol) {
        self.repository = repository
    }

    func getBanks() -> AnyPublisher<[Bank], APIError> {
        repository.getBanks()
    }
}
