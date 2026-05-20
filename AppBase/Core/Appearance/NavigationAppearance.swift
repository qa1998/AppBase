//
//  NavigationAppearance.swift
//  AppBase
//

import UIKit

final class NavigationAppearance {

    func apply() {
        let colors = ThemeManager.shared.palette
        let appearance = Self.makeBarAppearance(colors: colors)

        let barAppearance = UINavigationBar.appearance()
        barAppearance.standardAppearance = appearance
        barAppearance.scrollEdgeAppearance = appearance
        barAppearance.compactAppearance = appearance
        barAppearance.tintColor = colors.primary
    }

    func apply(to navigationBar: UINavigationBar) {
        let colors = ThemeManager.shared.palette
        let appearance = Self.makeBarAppearance(colors: colors)
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = colors.primary
    }

    static func makeBarAppearance(colors: ThemeColors) -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = colors.backgroundPrimary
        appearance.shadowColor = .clear

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: colors.textPrimary,
            .font: Font.bold(size: .text17)
        ]
        appearance.titleTextAttributes = titleAttributes
        appearance.largeTitleTextAttributes = [
            .foregroundColor: colors.textPrimary,
            .font: Font.bold(size: .text28)
        ]
        return appearance
    }
}
