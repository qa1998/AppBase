//
//  OnBoardCoordinator.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
import BaseMVVM

class OnBoardCoordinator: Coordinator<VoidMeta> {

    private lazy var rootVc: UIViewController = {
        let vc = OnBoardViewController()
        let vm = OnBoardViewModel()
        vc.invoke(viewModel: vm)
        return vc
    }()

    override var rootViewController: UIViewController {
        rootVc
    }
}
