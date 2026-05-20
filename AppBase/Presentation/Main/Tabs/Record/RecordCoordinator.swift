//
//  RecordCoordinator.swift
//  AppBase
//

import UIKit
import BaseMVVM
import Combine

class RecordCoordinator: NavigationCoordinator<VoidMeta> {

    private lazy var rootVC: UIViewController = {
        let viewController = RecordViewController()
        let viewModel = RecordViewModel()
        viewModel.pushTestScreen
            .sink { [weak self] step in
                self?.pushTestScreen(step: step)
            }
            .store(in: &cancelBag)
        viewController.invoke(viewModel: viewModel)
        return viewController
    }()

    override func start() {
        super.start()
        navigate(to: .set([rootVC]), transitioning: .none)
    }

    private func pushTestScreen(step: Int) {
        let viewController = RecordTestViewController()
        let viewModel = RecordTestViewModel(step: step)
        bindTestNavigation(viewModel)
        viewController.invoke(viewModel: viewModel)
        navigate(to: .push(viewController))
    }

    private func bindTestNavigation(_ viewModel: RecordTestViewModel) {
        viewModel.navigationAction
            .sink { [weak self] action in
                self?.handleTestNavigation(action)
            }
            .store(in: &cancelBag)
    }

    private func handleTestNavigation(_ action: RecordTestNavigation) {
        switch action {
        case .pop:
            navigate(to: .pop)
        case let .push(step):
            pushTestScreen(step: step)
        }
    }
}
