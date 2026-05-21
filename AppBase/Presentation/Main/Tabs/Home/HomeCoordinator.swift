//
//  HomeCoordinator.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
import BaseMVVM

class HomeCoordinator: NavigationCoordinator<VoidMeta> {

    private let dependencies: AppDependencies

    init(
        navigationController: UINavigationController,
        dependencies: AppDependencies
    ) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }

    private lazy var rootVC: UIViewController = {
        let viewController = HomeViewController()
        let viewModel = HomeViewModel(bankListUseCase: dependencies.bankList)
        viewController.invoke(viewModel: viewModel)
        return viewController
    }()

    override func start() {
        super.start()
        navigate(to: .set([rootVC]), transitioning: .none)
    }
}
