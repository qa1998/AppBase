//
//  LocalizationRefresh.swift
//  AppBase
//

import UIKit

enum LocalizationRefresh {

    static func refreshVisibleUI() {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                guard let root = window.rootViewController else { continue }
                refresh(in: root)
            }
        }
        NotificationCenter.default.post(name: .localizationDidChange, object: nil)
    }

    private static func refresh(in viewController: UIViewController) {
        if let refreshable = viewController as? LocalizationRefreshable {
            refreshable.refreshLocalization()
        }
        if let navigationRefresh = viewController as? NavigationLocalizationRefresh {
            navigationRefresh.refreshNavigationLocalization()
        }

        if let nav = viewController as? UINavigationController {
            nav.viewControllers.forEach { refresh(in: $0) }
        }

        if let tab = viewController as? UITabBarController {
            tab.viewControllers?.forEach { refresh(in: $0) }
        }

        viewController.children.forEach { refresh(in: $0) }

        if let presented = viewController.presentedViewController {
            refresh(in: presented)
        }
    }
}
