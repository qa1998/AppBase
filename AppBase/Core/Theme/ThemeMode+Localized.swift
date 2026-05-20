//
//  ThemeMode+Localized.swift
//  AppBase
//

import Foundation

extension ThemeMode {

    var localizedTitle: String {
        switch self {
        case .system:
            return L10n.Settings.Theme.system
        case .light:
            return L10n.Settings.Theme.light
        case .dark:
            return L10n.Settings.Theme.dark
        }
    }

    static var allCases: [ThemeMode] {
        [.system, .light, .dark]
    }
}
