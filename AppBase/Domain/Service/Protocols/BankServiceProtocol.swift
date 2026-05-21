//
//  BankServiceProtocol.swift
//  AppBase
//

import Combine
import Foundation

protocol BankServiceProtocol: AnyObject {

    func getBanks() -> AnyPublisher<[Bank], APIError>
}
