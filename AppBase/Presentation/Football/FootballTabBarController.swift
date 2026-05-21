//
//  FootballTabBarController.swift
//  AppBase
//

import Combine
import UIKit

/// Tab bar gốc Football — mỗi tab một `UINavigationController` + coordinator (giống `MainViewController`).
final class FootballTabBarController: ESTabBarController {

    enum Tab: Int, CaseIterable {
        case lineups = 0
        case teams = 1
        case players = 2
        case matches = 3
        case settings = 4
    }

    private var themeCancel: AnyCancellable?
    private var coordinators: [Coordinator<VoidMeta>] = []
    private var navigationControllers: [UINavigationController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureAppearance()
        installTabs()
        themeCancel = NotificationCenter.default.publisher(for: .footballThemeDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureAppearance()
            }
    }

    func refreshLocalization() {
        guard let items = tabBar.items, items.count >= Tab.allCases.count else { return }
        items[Tab.lineups.rawValue].title = L10n.Football.Tab.lineups
        items[Tab.teams.rawValue].title = L10n.Football.Tab.teams
        items[Tab.players.rawValue].title = L10n.Football.Tab.players
        items[Tab.matches.rawValue].title = L10n.Football.Tab.matches
        items[Tab.settings.rawValue].title = L10n.Football.Tab.settings
    }

    private func installTabs() {
        navigationControllers = Tab.allCases.map { tab in
            let nav = UINavigationController()
            nav.tabBarItem = makeTabBarItem(for: tab)
            nav.applyFootballNavigationChrome()
            return nav
        }

        coordinators = [
            FootballLineupsCoordinator(
                navigationController: navigationControllers[Tab.lineups.rawValue],
                tabController: self
            ),
            FootballTeamsCoordinator(
                navigationController: navigationControllers[Tab.teams.rawValue],
                tabController: self
            ),
            FootballPlayersCoordinator(
                navigationController: navigationControllers[Tab.players.rawValue],
                tabController: self
            ),
            FootballMatchesCoordinator(
                navigationController: navigationControllers[Tab.matches.rawValue],
                tabController: self
            ),
            FootballSettingsCoordinator(
                navigationController: navigationControllers[Tab.settings.rawValue],
                tabController: self
            ),
        ]
        coordinators.forEach { $0.start() }

        viewControllers = navigationControllers
        selectedIndex = Tab.lineups.rawValue
        refreshLocalization()
    }

    private func makeTabBarItem(for tab: Tab) -> UITabBarItem {
        switch tab {
        case .lineups:
            return UITabBarItem(
                title: L10n.Football.Tab.lineups,
                image: UIImage(systemName: "sportscourt.fill"),
                tag: tab.rawValue
            )
        case .teams:
            return UITabBarItem(
                title: L10n.Football.Tab.teams,
                image: UIImage(systemName: "person.3.fill"),
                tag: tab.rawValue
            )
        case .players:
            return UITabBarItem(
                title: L10n.Football.Tab.players,
                image: UIImage(systemName: "person.crop.circle.badge.plus"),
                tag: tab.rawValue
            )
        case .matches:
            return UITabBarItem(
                title: L10n.Football.Tab.matches,
                image: UIImage(systemName: "soccerball"),
                tag: tab.rawValue
            )
        case .settings:
            return UITabBarItem(
                title: L10n.Football.Tab.settings,
                image: UIImage(systemName: "gearshape.fill"),
                tag: tab.rawValue
            )
        }
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

    func updateTabBarVisibility(for navigationController: UINavigationController) {
        tabBar.isHidden = navigationController.viewControllers.count > 1
    }

    static func applyNavigationBarVisibility(
        on navigationController: UINavigationController,
        for viewController: UIViewController,
        animated: Bool
    ) {
        let hideNav = viewController is MyLineupsViewController
            || viewController is MyTeamsViewController
            || viewController is MyPlayersViewController
            || viewController is FootballMatchesViewController
            || viewController is FootballSettingsViewController
        navigationController.setNavigationBarHidden(hideNav, animated: animated)
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
        let hideNav = root is MyLineupsViewController
            || root is MyTeamsViewController
            || root is MyPlayersViewController
            || root is FootballMatchesViewController
        nav.setNavigationBarHidden(hideNav, animated: false)
        updateTabBarVisibility(for: nav)
    }
}
