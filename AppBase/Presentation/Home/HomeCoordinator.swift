//
//  HomeCoordinator.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
class HomeCoordinator: NavigationCoordinator<VoidMeta> {
    private lazy var rootVC:  UIViewController = {
        let vc = HomeViewController()
        return vc
    }()
    
    override func start() {
        super.start()
        self.navigate(to: .set([rootVC]))
    }
}
