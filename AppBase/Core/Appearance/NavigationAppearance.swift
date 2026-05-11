//
//  NavigationAppearance.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
final class NavigationAppearance {
    
    func apply() {
        
        let appearance =
        UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor =
        ThemeManager.shared
            .colors
            .backgroundPrimary
        
        appearance.titleTextAttributes = [
            .foregroundColor:
                ThemeManager.shared
                .colors
                .textPrimary,
            
                .font:
                Font.bold(size: .text17)
        ]
        
        appearance.shadowColor = .clear
        
        UINavigationBar.appearance()
            .standardAppearance = appearance
        
        UINavigationBar.appearance()
            .scrollEdgeAppearance = appearance
        
        UINavigationBar.appearance()
            .compactAppearance = appearance
    }
}
