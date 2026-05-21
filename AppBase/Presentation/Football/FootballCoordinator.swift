//
//  FootballCoordinator.swift
//  AppBase
//

import UIKit

/// Root coordinator Football — root là tab bar, không bọc thêm navigation (giống `MainCoordinator`).
final class FootballCoordinator: Coordinator<VoidMeta> {

    private lazy var rootVc: UIViewController = FootballTabBarController()

    override var rootViewController: UIViewController {
        rootVc
    }

    override func start() {
        super.start()
    }
}
