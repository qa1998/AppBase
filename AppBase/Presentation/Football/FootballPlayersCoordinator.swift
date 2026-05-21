//
//  FootballPlayersCoordinator.swift
//  AppBase
//

import BaseMVVM
import UIKit

final class FootballPlayersCoordinator: FootballTabNavigationCoordinator<VoidMeta> {

    override init(navigationController: UINavigationController, tabController: FootballTabBarController) {
        super.init(navigationController: navigationController, tabController: tabController)
    }

    private lazy var rootVC: UIViewController = {
        let vc = MyPlayersViewController()
        vc.invoke(viewModel: MyPlayersViewModel())
        vc.onCreatePlayer = { [weak self] in
            self?.pushPlayerEditor()
        }
        vc.onOpenPlayer = { [weak self] _ in
            self?.pushPlayerEditor()
        }
        return vc
    }()

    override func start() {
        super.start()
        navigate(to: .set([rootVC]), animated: false, transitioning: nil)
    }

    private func pushPlayerEditor() {
        let vc = PlayerEditorViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.invoke(viewModel: PlayerEditorViewModel())
        vc.onSaved = { [weak vc] in
            vc?.navigationController?.popViewController(animated: true)
        }
        navigate(to: .push(vc))
    }
}
