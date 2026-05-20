//
//  MaintanceCoordinator.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
import BaseMVVM

class MaintanceCoordinator: Coordinator<VoidMeta> {

    private lazy var rootVc: UIViewController = {
        let vc = MaintanceViewController()
        let vm = MaintanceViewModel()
        vc.invoke(viewModel: vm)
        return vc
    }()

    override var rootViewController: UIViewController {
        rootVc
    }
}
