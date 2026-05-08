//
//  LoginCoordinator.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
class LoginCoordinator: Coordinator<VoidMeta> {
    private lazy var rootVc: UIViewController = {
        let vc = MainViewController()
        return vc
    }()
    
    override var rootViewController: UIViewController {
        return rootVc
    }
}




