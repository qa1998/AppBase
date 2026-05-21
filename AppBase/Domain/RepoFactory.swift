//
//  RepoFactory.swift
//  AppBase
//

import Foundation

enum RepoFactory {

    static func makeHomeRepository(useFake: Bool) -> HomeRepositoryProtocol {
        useFake ? HomeFakeRepository() : HomeRepository()
    }

    static func makeBankRepository(useFake: Bool) -> BankRepositoryProtocol {
        useFake ? BankFakeRepository() : BankRepository()
    }
}
