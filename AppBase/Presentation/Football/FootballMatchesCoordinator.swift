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
        vc.onCreateMatch = { [weak self] in
            self?.pushCreateMatch()
        }
        vc.onOpenMatch = { [weak self] match in
            MatchStore.shared.loadMatch(match)
            self?.pushMatchLive()
        }
        return vc
    }()

    override func start() {
        super.start()
        navigate(to: .set([rootVC]), animated: false, transitioning: nil)
    }

    private func pushCreateMatch() {
        let viewModel = CreateMatchViewModel()
        let vc = CreateMatchViewController()
        vc.invoke(viewModel: viewModel)
        vc.onPickHomeTeam = { [weak self, weak vc] in
            guard let self, let vc else { return }
            self.presentTeamPicker(from: vc, pitchSize: viewModel.pitchSize) { team in
                viewModel.applySavedTeam(team, side: .home)
                vc.reloadFromViewModel()
            }
        }
        vc.onPickAwayTeam = { [weak self, weak vc] in
            guard let self, let vc else { return }
            self.presentTeamPicker(from: vc, pitchSize: viewModel.pitchSize) { team in
                viewModel.applySavedTeam(team, side: .away)
                vc.reloadFromViewModel()
            }
        }
        vc.onContinue = { [weak self] in
            guard let self else { return }
            if viewModel.canSkipTeamSetup, viewModel.createMatch() != nil {
                let keep = self.navigationController.viewControllers.filter {
                    !($0 is CreateMatchViewController)
                }
                self.navigate(to: .set(keep), animated: false)
                self.pushMatchLive()
            } else {
                self.pushMatchTeamsSetup(viewModel: viewModel)
            }
        }
        navigate(to: .push(vc))
    }

    private func presentTeamPicker(
        from presenter: UIViewController,
        pitchSize: MatchPitchSize,
        onSelect: @escaping (FootballTeam) -> Void
    ) {
        let vc = TeamPickerViewController()
        vc.invoke(viewModel: TeamPickerViewModel(pitchSize: pitchSize))
        vc.onSelect = { team in
            onSelect(team)
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.applyFootballNavigationChrome()
        presenter.present(nav, animated: true)
    }

    private func pushMatchTeamsSetup(viewModel: CreateMatchViewModel) {
        let vc = MatchTeamsSetupViewController()
        vc.invoke(viewModel: viewModel)
        vc.onPickPlayer = { [weak self, weak vc] side, slot, handler in
            self?.pushMatchPlayerPicker(side: side, rosterSlot: slot, onPicked: handler, from: vc)
        }
        vc.onFinished = { [weak self] in
            guard let self, MatchStore.shared.currentMatch != nil else { return }
            let keep = self.navigationController.viewControllers.filter {
                !($0 is CreateMatchViewController || $0 is MatchTeamsSetupViewController)
            }
            self.navigate(to: .set(keep), animated: false)
            self.pushMatchLive()
        }
        navigate(to: .push(vc))
    }

    private func pushMatchPlayerPicker(
        side: MatchTeamSide,
        rosterSlot: MatchRosterSlot,
        onPicked: @escaping (FootballPlayer) -> Void,
        from presenter: UIViewController?
    ) {
        let pickerSlot: Int = {
            switch rosterSlot {
            case .pitch(let index): return index
            case .bench(let index): return index
            }
        }()
        let vc = PlayerPickerViewController()
        vc.invoke(viewModel: PlayerPickerViewModel(slotIndex: pickerSlot, onPlayerSelected: onPicked))
        self.navigate(to: .push(vc))
    }

    private func pushMatchLive() {
        guard let match = MatchStore.shared.currentMatch else { return }
        if navigationController.topViewController is MatchLiveViewController {
            return
        }
        let vc = MatchLiveViewController()
        vc.invoke(viewModel: MatchLiveViewModel(match: match))
        navigate(to: .push(vc))
    }
}
