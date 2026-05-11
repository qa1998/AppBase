//
//  TabBarAppearance.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
final class TabBarAppearance {
    
    func apply() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ThemeManager.shared.colors.backgroundPrimary
        
        UITabBar.appearance()
            .standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            
            UITabBar.appearance()
                .scrollEdgeAppearance = appearance
        }
    }
}
