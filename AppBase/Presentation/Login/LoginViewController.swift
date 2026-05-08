//
//  LoginViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//
import UIKit
import Combine
import BaseMVVM

class LoginViewController<VM: LoginViewModel>: TIOViewController<VM> {
    let navToRegister = PassthroughSubject<Void, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        self.title = "Login"
        
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAdd)
        )
        
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func didTapAdd() {
        navToRegister.send()
    }
}



class RegisterViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "Register"
        
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAdd)
        )
        
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func didTapAdd() {
        AppStateEvent.set(state: .main)
    }
    
}
