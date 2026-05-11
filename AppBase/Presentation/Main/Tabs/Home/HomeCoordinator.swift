//
//  HomeCoordinator.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
import BaseMVVM

class HomeCoordinator: NavigationCoordinator<VoidMeta> {
    
    private var rootVC:  UIViewController = {
        let vc = HomeViewController()
        let vm = HomeViewModel()
        vc.invoke(viewModel: vm)
        return vc
    }()
    
    override func start() {
        super.start()
        self.navigate(to: .set([rootVC]))
    }
}
