//
//  MainCoordinaor.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit

class MainCoordinator: Coordinator<VoidMeta> {

    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        super.init()
    }

    private lazy var rootVc: UIViewController = {
        MainViewController(dependencies: dependencies)
    }()

    override var rootViewController: UIViewController {
        rootVc
    }
}
