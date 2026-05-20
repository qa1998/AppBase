//
//  AppAppearance+Runtime.swift
//  AppBase
//

import UIKit

extension AppAppearance {

    /// Áp theme lên appearance proxy + mọi Navigation/Tab bar đang hiển thị.
    func applyIncludingVisibleBars() {
        apply()
        applyToVisibleBars()
    }

    func applyToVisibleBars() {
        let colors = ThemeManager.shared.palette

        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                guard let root = window.rootViewController else { continue }
                applyAppearance(to: root, colors: colors)
            }
        }
    }

    private func applyAppearance(to root: UIViewController, colors: ThemeColors) {
        if let nav = root as? UINavigationController {
            navigation.apply(to: nav.navigationBar)
        }

        if let tab = root as? UITabBarController {
            tabBar.apply(to: tab.tabBar)
            ESTabBarAppearance.apply(to: tab.tabBar, colors: colors)
        }

        for child in root.children {
            applyAppearance(to: child, colors: colors)
        }

        if let presented = root.presentedViewController {
            applyAppearance(to: presented, colors: colors)
        }

        if let nav = root as? UINavigationController {
            for vc in nav.viewControllers {
                applyAppearance(to: vc, colors: colors)
            }
        } else if let tab = root as? UITabBarController {
            tab.viewControllers?.forEach { applyAppearance(to: $0, colors: colors) }
        }
    }
}
