//
//  TabBarAppearance.swift
//  AppBase
//

import UIKit

final class TabBarAppearance {

    func apply() {
        let colors = ThemeManager.shared.palette
        let appearance = Self.makeBarAppearance(colors: colors)

        let barAppearance = UITabBar.appearance()
        barAppearance.standardAppearance = appearance
        barAppearance.tintColor = colors.primary
        barAppearance.unselectedItemTintColor = colors.textSecondary
        if #available(iOS 15.0, *) {
            barAppearance.scrollEdgeAppearance = appearance
        }
    }

    func apply(to tabBar: UITabBar) {
        let colors = ThemeManager.shared.palette
        let appearance = Self.makeBarAppearance(colors: colors)
        tabBar.standardAppearance = appearance
        tabBar.tintColor = colors.primary
        tabBar.unselectedItemTintColor = colors.textSecondary
        tabBar.barTintColor = colors.backgroundPrimary
        tabBar.backgroundColor = colors.backgroundPrimary
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }

    static func makeBarAppearance(colors: ThemeColors) -> UITabBarAppearance {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = colors.backgroundPrimary
        appearance.shadowColor = colors.separator

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = colors.textSecondary
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: colors.textSecondary,
            .font: Font.default(size: .text10)
        ]
        itemAppearance.selected.iconColor = colors.primary
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: colors.primary,
            .font: Font.bold(size: .text10)
        ]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        return appearance
    }
}
