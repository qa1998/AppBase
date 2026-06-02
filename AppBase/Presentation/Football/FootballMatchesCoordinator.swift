//
//  FootballMatchesCoordinator.swift
//  AppBase
//

import BaseMVVM
import UIKit

final class FootballMatchesCoordinator: FootballTabNavigationCoordinator<VoidMeta> {

    override init(navigationController: UINavigationController, tabController: FootballTabBarController) {
        super.init(navigationController: navigationController, tabController: tabController)
    }

    private lazy var rootVC: UIViewController = {
        let vc = FootballMatchesViewController()
        vc.invoke(viewModel: FootballMatchesViewModel())
        vc.onAddScore = { [weak self] in
            self?.pushEnterScore(editing: nil)
        }
        vc.onOpenMatch = { [weak self] match in
            self?.pushEnterScore(editing: match)
        }
        return vc
    }()

    override func start() {
        super.start()
        navigate(to: .set([rootVC]), animated: false, transitioning: nil)
    }

    private func pushEnterScore(editing match: FootballMatch?) {
        let viewModel = EnterScoreViewModel(match: match)
        let vc = EnterScoreViewController()
        vc.invoke(viewModel: viewModel)
        vc.onSaved = { [weak self] in
            self?.navigate(to: .pop)
        }
        navigate(to: .push(vc))
    }
}
