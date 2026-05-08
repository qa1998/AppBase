//
//  LoginCoordinator.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
import BaseMVVM
import Combine

class LoginCoordinator: NavigationCoordinator<VoidMeta> {
    
    private lazy var rootVc: UIViewController = {
        let vc = LoginViewController()
        let vm = LoginViewModel()
        vc.navToRegister.sink { [weak self] in
            self?.navToRegíter()
        }.store(in: &cancelBag)
        vc.invoke(viewModel: vm)
        return vc
    }()
    
    override func start() {
        self.navigate(to: .set([rootVc]), transitioning: .none)
    }
    
    private func navToRegíter() {
        let vc = RegisterViewController()
        self.navigate(to: .push(vc))
    }
}



