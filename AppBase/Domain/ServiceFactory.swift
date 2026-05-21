//
//  ServiceFactory.swift
//  AppBase
//

import Foundation

enum ServiceFactory {

    static func makeHomeService(repository: HomeRepositoryProtocol) -> HomeServiceProtocol {
        HomeServiceImpl(repository: repository)
    }

    static func makeBankService(repository: BankRepositoryProtocol) -> BankServiceProtocol {
        BankServiceImpl(repository: repository)
    }
}
