//
//  RecordCoordinator.swift
//  AppBase
//

import UIKit
import BaseMVVM

class RecordCoordinator: NavigationCoordinator<VoidMeta> {

    private lazy var rootVC: UIViewController = {
        let viewController = RecordViewController()
        viewController.invoke(viewModel: RecordViewModel())
        return viewController
    }()

    override func start() {
        super.start()
        navigate(to: .set([rootVC]), transitioning: .none)
    }
}
