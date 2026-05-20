//
//  LibraryCoordinator.swift
//  AppBase
//

import UIKit
import BaseMVVM

class LibraryCoordinator: NavigationCoordinator<VoidMeta> {

    private lazy var rootVC: UIViewController = {
        let viewController = LibraryViewController()
        viewController.invoke(viewModel: LibraryViewModel())
        return viewController
    }()

    override func start() {
        super.start()
        navigate(to: .set([rootVC]), transitioning: .none)
    }
}
