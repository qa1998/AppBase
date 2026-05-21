//
//  LibraryCoordinator.swift
//  AppBase
//

import UIKit
import BaseMVVM

class LibraryCoordinator: NavigationCoordinator<VoidMeta> {

    private let dependencies: AppDependencies

    init(
        navigationController: UINavigationController,
        dependencies: AppDependencies
    ) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }

    private lazy var rootVC: UIViewController = {
        let viewController = LibraryViewController()
        let viewModel = LibraryViewModel(repository: dependencies.libraryRepository)
        viewController.invoke(viewModel: viewModel)
        return viewController
    }()

    override func start() {
        super.start()
        navigate(to: .set([rootVC]), transitioning: .none)
    }
}
