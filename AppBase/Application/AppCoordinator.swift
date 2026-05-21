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

    private lazy var splashVC: UIViewController = {
        let vc = SplashViewController()
        let vm = SplashViewModel()
        vc.invoke(viewModel: vm)
        return vc
    }()

    override var rootViewController: UIViewController {
        splashVC
    }

    private let window: UIWindow
    private let dependencies: AppDependencies

    init(
        window: UIWindow,
        dependencies: AppDependencies = AppDependencies.make()
    ) {
        self.window = window
        self.dependencies = dependencies
    }

    private func bind() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }

    private func bindAppState() {
        AppStateEvent.default.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] appState in
                self?.trigger(state: appState)
            }
            .store(in: &cancelBag)
    }

    private func trigger(state: AppState) {
        finishAllChildren()
        removeAll()

        switch state {
        case .main:
            runMainFlow()
        case .login, .logout:
            if state == .logout {
                AppData.shared.token = ""
            }
            runSignInFlow()
        case .maintain:
            runMaintainFlow()
        case .welcome:
            runWellCome()
        }
    }

    private func finishAllChildren() {
        coordinators.forEach { wrapper in
            (wrapper.coordinator as? Coordinator<VoidMeta>)?.finish()
        }
    }

    override func start() {
        super.start()
        ThemeManager.shared.apply()
        AppAppearance.shared.apply()
        bind()
        bindAppState()
    }
}

extension AppCoordinator {
    private func runMainFlow() {
        applyFootballWindowStyle()
        let football = footballCoor()
        add(football)
        football.start()
        replaceRoot(football.rootViewController, animated: true)
    }

    private func applyFootballWindowStyle() {
        if ThemeManager.shared.mode == .system {
            ThemeManager.shared.mode = .dark
        }
        FootballAppearance.syncFromThemeManager()
    }

    private func runSignInFlow() {
        let login = loginCoor()
        add(login)
        replaceRoot(login.rootViewController)
    }

    private func runMaintainFlow() {
        let maintance = maintanceCoor()
        add(maintance)
        replaceRoot(maintance.rootViewController)
    }

    private func runWellCome() {
        let onBoard = onBoardCoor()
        add(onBoard)
        replaceRoot(onBoard.rootViewController)
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

    private func footballCoor() -> FootballCoordinator {
        FootballCoordinator(entryPoint: .tabs)
    }

    private func onBoardCoor() -> Coordinator<VoidMeta> {
        OnBoardCoordinator()
    }

    private func loginCoor() -> Coordinator<VoidMeta> {
        let nav = UINavigationController()
        let loginCoor = LoginCoordinator(navigationController: nav)
        loginCoor.start()
        return loginCoor
    }

    private func maintanceCoor() -> Coordinator<VoidMeta> {
        MaintanceCoordinator()
    }
}
