//
//  BankRepositoryProtocol.swift
//  AppBase
//

import Combine
import Foundation

protocol BankRepositoryProtocol: AnyObject {

    func getBanks() -> AnyPublisher<[Bank], APIError>
}
