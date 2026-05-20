//
//  LoginViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
import Combine
import BaseMVVM

class LoginViewController<VM: LoginViewModel>: TIOScreenViewController<VM> {

    let navToRegister = PassthroughSubject<Void, Never>()

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshLocalization()

        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAdd)
        )
        navigationItem.rightBarButtonItem = addButton
    }

    override func refreshLocalization() {
        title = L10n.Login.title
    }

    @objc private func didTapAdd() {
        navToRegister.send()
    }
}

class RegisterViewController: TIOScreenViewController<RegisterViewModel> {

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshLocalization()

        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAdd)
        )
        navigationItem.rightBarButtonItem = addButton
    }

    override func refreshLocalization() {
        title = L10n.Login.Register.title
    }

    @objc private func didTapAdd() {
        AppStateEvent.set(state: .main)
    }
}
