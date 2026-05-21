//
//  FootballTabBarController.swift
//  AppBase
//

import Combine
import UIKit

/// Bottom navigation — Lineups · Matches · Settings.
final class FootballTabBarController: UITabBarController {

    enum Tab: Int, CaseIterable {
        case lineups = 0
        case matches = 1
        case settings = 2
    }

    private var themeCancel: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureAppearance()
        refreshLocalization()
        themeCancel = NotificationCenter.default.publisher(for: .footballThemeDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureAppearance()
            }
    }

    func refreshLocalization() {
        guard let items = tabBar.items, items.count >= Tab.allCases.count else { return }
        items[Tab.lineups.rawValue].title = L10n.Football.Tab.lineups
        items[Tab.matches.rawValue].title = L10n.Football.Tab.matches
        items[Tab.settings.rawValue].title = L10n.Football.Tab.settings
    }

    private func configureAppearance() {
        let isLight = ThemeManager.shared.mode == .light
        tabBar.barStyle = isLight ? .default : .black
        tabBar.isTranslucent = true
        tabBar.backgroundImage = UIImage()
        tabBar.backgroundColor = FootballPalette.surface.withAlphaComponent(0.92)
        tabBar.tintColor = FootballPalette.accentGreen
        tabBar.unselectedItemTintColor = FootballPalette.textSecondary
    }

    private func updateTabBarVisibility(for navigationController: UINavigationController) {
        tabBar.isHidden = navigationController.viewControllers.count > 1
    }
}

// MARK: - UITabBarControllerDelegate

extension FootballTabBarController: UITabBarControllerDelegate {

    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        guard let nav = viewController as? UINavigationController else { return }
        let root = nav.viewControllers.first
        let hideNav = root is MyLineupsViewController || root is FootballMatchesViewController
        nav.setNavigationBarHidden(hideNav, animated: false)
        updateTabBarVisibility(for: nav)
    }
}

// MARK: - UINavigationControllerDelegate

extension FootballTabBarController: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        updateTabBarVisibility(for: navigationController)
    }
}
