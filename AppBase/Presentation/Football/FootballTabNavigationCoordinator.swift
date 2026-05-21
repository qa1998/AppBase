//
//  FootballTabNavigationCoordinator.swift
//  AppBase
//

import UIKit

/// Tab stack coordinator — giữ `NavigationCoordinator` pop tracking + ẩn/hiện tab bar & nav bar.
class FootballTabNavigationCoordinator<M: CoordinationMeta>: NavigationCoordinator<M> {

    private weak var tabController: FootballTabBarController?

    init(
        navigationController: UINavigationController,
        tabController: FootballTabBarController
    ) {
        self.tabController = tabController
        super.init(navigationController: navigationController)
    }

    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        FootballTabBarController.applyNavigationBarVisibility(
            on: navigationController,
            for: viewController,
            animated: animated
        )
        tabController?.updateTabBarVisibility(for: navigationController)
        tabController?.updateDemoBanner(for: navigationController)
    }

    override func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        super.navigationController(navigationController, didShow: viewController, animated: animated)
        tabController?.updateTabBarVisibility(for: navigationController)
        tabController?.updateDemoBanner(for: navigationController)
    }
}
