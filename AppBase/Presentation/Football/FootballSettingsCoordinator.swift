//
//  FootballSettingsCoordinator.swift
//  AppBase
//

import BaseMVVM
import UIKit

final class FootballSettingsCoordinator: FootballTabNavigationCoordinator<VoidMeta> {

    override init(navigationController: UINavigationController, tabController: FootballTabBarController) {
        super.init(navigationController: navigationController, tabController: tabController)
    }

    private lazy var rootVC: UIViewController = {
        let vc = FootballSettingsViewController()
        vc.invoke(viewModel: FootballSettingsViewModel())
        return vc
    }()

    override func start() {
        super.start()
        navigate(to: .set([rootVC]), animated: false, transitioning: nil)
    }
}
