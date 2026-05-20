//
//  ScriptsCoordinator.swift
//  AppBase
//

import UIKit
import BaseMVVM

class ScriptsCoordinator: NavigationCoordinator<VoidMeta> {

    private lazy var rootVC: UIViewController = {
        let viewController = ScriptsViewController()
        viewController.invoke(viewModel: ScriptsViewModel())
        return viewController
    }()

    override func start() {
        super.start()
        navigate(to: .set([rootVC]), transitioning: .none)
    }
}
