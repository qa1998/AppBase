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
            self?.navToRegister()
        }.store(in: &cancelBag)
        vc.invoke(viewModel: vm)
        return vc
    }()

    override func start() {
        navigate(to: .set([rootVc]), transitioning: .none)
    }

    private func navToRegister() {
        let vc = RegisterViewController()
        let vm = RegisterViewModel()
        vc.invoke(viewModel: vm)
        navigate(to: .push(vc))
    }
}
