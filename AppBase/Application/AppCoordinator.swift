//
//  AppCoordinator.swift
//  AppBase
//
//  Created by QuangAnh on 7/5/26.
//

import Combine
import Foundation
import UIKit

struct VoidMeta: CoordinationMeta {}

class AppCoordinator: Coordinator<VoidMeta> {
    
    private lazy var loginCoor: Coordinator = {
        let loginCoor = LoginCoordinator()
        return loginCoor
    }()
    
    private lazy var mainCoor: Coordinator = {
        let mainCoor = MainCoordinator()
        return mainCoor
    }()
    
    private lazy var maintanceCoor: Coordinator = {
        let maintanceCoor = MaintanceCoordinator()
        return maintanceCoor
    }()
    
    private lazy var rootVC: UIViewController = {
        let vc = SplashViewController()
        return vc
    }()
    
    override var rootViewController: UIViewController {
        return rootVC
    }
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    private func bind() {
        let vc = rootViewController
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
    
    private func bindAppState() {
        AppStateEvent.default.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] appState in
            self?.trigger(state: appState)
        }.store(in: &cancelBag)
    }
    
    private func trigger(state: AppState) {
        switch state {
        case .main: runMainFlow()
        case .login: runSignInFlow()
        case .maintain: runMaintainFlow()
        default: break
        }
    }
    
    override func start() {
        bind()
        bindAppState()
    }
}

extension AppCoordinator {
    private func runMainFlow() {
        self.add(mainCoor)
        self.replaceRoot(mainCoor.rootViewController)
    }
    
    private func runSignInFlow() {
        self.add(loginCoor)
        self.replaceRoot(loginCoor.rootViewController)
    }
    
    private func runMaintainFlow() {
        self.add(maintanceCoor)
        self.replaceRoot(maintanceCoor.rootViewController)
    }
}

extension AppCoordinator {
    func replaceRoot(_ viewController: UIViewController, animated: Bool = false) {
        guard animated else {
            window.rootViewController = viewController
            window.makeKeyAndVisible()
            return
        }
        UIView.transition(
            with: window,
            duration: 0.25,
            options: [.transitionCrossDissolve]
        ) {
            let oldState = UIView.areAnimationsEnabled
            
            UIView.setAnimationsEnabled(false)
            
            self.window.rootViewController = viewController
            
            UIView.setAnimationsEnabled(oldState)
        }
    }
}
