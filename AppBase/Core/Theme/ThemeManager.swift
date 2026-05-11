//
//  ThemeManager.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
import Combine

final class ThemeManager: ObservableObject {
    
    static let shared = ThemeManager()
    
    @Published var mode: ThemeMode {
        didSet {
            save()
            apply()
        }
    }
    
    var colors: ThemeColors {
        switch mode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            let style = UIScreen.main.traitCollection.userInterfaceStyle
            return style == .dark
            ? .dark
            : .light
        }
    }
    
    private init() {
        
        self.mode = ThemeMode(
            rawValue: UserDefaults.standard.string(
                forKey: "theme_mode"
            ) ?? ""
        ) ?? .system
        
        apply()
    }
}

extension ThemeManager {
    
    func apply() {
        
        guard let windowScene = UIApplication.shared
            .connectedScenes
            .first as? UIWindowScene
        else {
            return
        }
        
        windowScene.windows.forEach {
            
            switch mode {
                
            case .system:
                $0.overrideUserInterfaceStyle = .unspecified
                
            case .light:
                $0.overrideUserInterfaceStyle = .light
                
            case .dark:
                $0.overrideUserInterfaceStyle = .dark
            }
        }
    }
}

// MARK: - Private

private extension ThemeManager {
    
    func save() {
        
        UserDefaults.standard.set(
            mode.rawValue,
            forKey: "theme_mode"
        )
    }
}
