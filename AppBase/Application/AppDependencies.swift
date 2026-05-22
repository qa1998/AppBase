//
//  AppDependencies.swift
//  AppBase
//

import Foundation

/// DI container — mở rộng khi nối UseCase / Repository cho Football hoặc Auth.
struct AppDependencies {

    static let live = AppDependencies()
    static let fake = AppDependencies()

    static func make(useFakeData: Bool? = nil) -> AppDependencies {
        AppDependencies()
    }
}
