//
//  OnBoardCoordinator.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
class OnBoardCoordinator: Coordinator<VoidMeta> {
    private lazy var rootVc: UIViewController = {
        let vc = OnBoardViewController()
        return vc
    }()
    
    override var rootViewController: UIViewController {
        return rootVc
    }
}
