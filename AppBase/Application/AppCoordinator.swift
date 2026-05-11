//
//  AppCoordinator.swift
//  AppBase
//
//  Created by QuangAnh on 7/5/26.
//

import Combine
import Foundation
import UIKit
import BaseMVVM

struct VoidMeta: CoordinationMeta {}

class AppCoordinator: Coordinator<VoidMeta> {
    
    private func createSplashVC() -> UIViewController {
        let vc = SplashViewController()
        let vm = SplashViewModel()
        vc.invoke(viewModel: vm)
        return vc
    }
    
    override var rootViewController: UIViewController {
        return createSplashVC()
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
        self.removeAll()
        switch state {
        case .main: runMainFlow()
        case .login: runSignInFlow()
        case .maintain: runMaintainFlow()
        case .welcome: runWellCome()
        default: break
        }
    }
    
    override func start() {
        ThemeManager.shared.apply()
        AppAppearance.shared.apply()
        
        bind()
        bindAppState()
    }
}

extension AppCoordinator {
    private func runMainFlow() {
        let main = mainCoor()
        self.add(main)
        self.replaceRoot(main.rootViewController)
    }
    
    private func runSignInFlow() {
        let login = loginCoor()
        self.add(login)
        self.replaceRoot(login.rootViewController)
    }
    
    private func runMaintainFlow() {
        let maitance = maintanceCoor()
        self.add(maitance)
        self.replaceRoot(maitance.rootViewController)
    }
    
    private func runWellCome() {
        let onBoard = onBoardCoor()
        self.add(onBoard)
        self.replaceRoot(onBoard.rootViewController)
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
    
    private func mainCoor() -> Coordinator<VoidMeta> {
        let mainCoor = MainCoordinator()
        return mainCoor
    }
    
    private func onBoardCoor() -> Coordinator<VoidMeta> {
        let onBoardCoor = OnBoardCoordinator()
        return onBoardCoor
    }
    
    private func loginCoor() -> Coordinator<VoidMeta> {
        let nav = UINavigationController()
        let loginCoor = LoginCoordinator(navigationController: nav)
        loginCoor.start()
        return loginCoor
    }
    
    private func maintanceCoor() -> Coordinator<VoidMeta> {
        let maintanceCoor = MaintanceCoordinator()
        return maintanceCoor
    }
}

