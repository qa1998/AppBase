//
//  AppAppearance.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//


final class AppAppearance {
    
    static let shared = AppAppearance()
    
    private init() {}
    
    func apply() {
        navigation.apply()
        tabBar.apply()
    }
    
    let navigation = NavigationAppearance()
    
    let tabBar = TabBarAppearance()
}
