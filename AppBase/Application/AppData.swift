//
//  AppData.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import Foundation
import Combine
import UIKit

class AppData: ObservableObject {
    
    static let shared = AppData()
    
    @Published var token: String {
        didSet {
            DataStore.shared.set(
                token,
                forKey: .token
            )
        }
    }
    
    @Published var isFirstLaunch: Bool {
        didSet {
            DataStore.shared.set(
                isFirstLaunch,
                forKey: .isFirstLaunch
            )
        }
    }
    
    var isLogin: Bool {
        !token.isEmpty
    }
    
    static var appVersion: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? ""
    }
    
    private init() {
        self.token = DataStore.shared.value(forKey: .token,type: String.self) ?? ""
        self.isFirstLaunch = DataStore.shared.value(forKey: .isFirstLaunch,type: Bool.self) ?? true
    }
}

