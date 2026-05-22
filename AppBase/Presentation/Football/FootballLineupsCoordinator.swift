//
//  FootballLineupsCoordinator.swift
//  AppBase
//

import BaseMVVM
import UIKit

final class FootballLineupsCoordinator: FootballTabNavigationCoordinator<VoidMeta> {

    override init(navigationController: UINavigationController, tabController: FootballTabBarController) {
        super.init(navigationController: navigationController, tabController: tabController)
    }

    private lazy var rootVC: UIViewController = {
        let vc = MyLineupsViewController()
        vc.invoke(viewModel: MyLineupsViewModel())
        vc.onCreateLineup = { [weak self] in
            self?.pushEditor(animated: true)
        }
        vc.onOpenLineup = { [weak self] _ in
            self?.pushEditor(animated: true)
        }
        vc.onShareLineup = { [weak self] lineup in
            self?.pushLineupShare(lineup)
        }
        vc.onPremiumTap = { [weak vc] in
            (vc as? MyLineupsViewController)?.showPremiumHint()
        }
        return vc
    }()

    override func start() {
        super.start()
        navigate(to: .set([rootVC]), animated: false, transitioning: nil)
    }

    func pushEditor(animated: Bool) {
        if navigationController.topViewController is LineupEditorViewController {
            return
        }
        if navigationController.viewControllers.count > 1 {
            navigationController.popToRootViewController(animated: false)
        }
        let vc = LineupEditorViewController()
        vc.invoke(viewModel: LineupEditorViewModel())
        wireEditor(vc)
        navigate(to: .push(vc), animated: animated)
    }

    private func wireEditor(_ vc: LineupEditorViewController) {
        vc.onPickPlayer = { [weak self, weak vc] slot in
            self?.pushPlayerPicker(slot: slot, from: vc)
        }
        vc.onPickBenchPlayer = { [weak self, weak vc] index in
            self?.pushBenchPlayerPicker(benchIndex: index, from: vc)
        }
        vc.onPickFormation = { [weak self, weak vc] in
            self?.presentFormationPicker(from: vc)
        }
        vc.onPickPitchOptions = { [weak self, weak vc] in
            self?.presentPitchOptions(from: vc)
        }
        vc.onPickLineOptions = { [weak self, weak vc] in
            self?.presentLineOptions(from: vc)
        }
        vc.onSaveLineup = { [weak vc] in
            vc?.navigationController?.popViewController(animated: true)
        }
        vc.onImportTeam = { [weak self, weak vc] in
            self?.presentTeamPickerForLineup(from: vc)
        }
        vc.onPickSettings = { [weak self, weak vc] in
            self?.pushLineupSettings(from: vc)
        }
    }

    private func pushLineupShare(_ lineup: FootballLineup) {
        let vc = LineupShareViewController()
        vc.invoke(viewModel: LineupShareViewModel(lineup: lineup))
        navigate(to: .push(vc))
    }

    private func pushLineupSettings(from presenter: UIViewController?) {
        guard let presenter else { return }
        let lineup = LineupStore.shared.currentLineup
        let settings = LineupEditorSettingsViewController()
        settings.invoke(viewModel: LineupEditorSettingsViewModel(title: lineup.title))
        settings.onDidSave = { [weak presenter] in
        }
        navigate(to: .push(settings))
    }

    private func presentTeamPickerForLineup(from presenter: UIViewController?) {
        let teams = TeamStore.shared.teams
        guard !teams.isEmpty else {
            (presenter as? LineupEditorViewController)?.viewModel.presentError(.empty)
            return
        }
        let vc = TeamPickerViewController()
        vc.invoke(viewModel: TeamPickerViewModel())
        vc.onSelect = { [weak presenter] team in
            (presenter as? LineupEditorViewController)?.viewModel.importTeam(team)
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.applyFootballNavigationChrome()
        navigate(to: .present(nav), animated: true)
    }

    private func presentFormationPicker(from presenter: UIViewController?) {
        guard let presenter else { return }
        let lineup = LineupStore.shared.currentLineup
        let picker = FormationPickerViewController(
            selectedFormationId: lineup.formationId,
            playerCount: lineup.playerCount
        )
        picker.onSelect = { formation in
            LineupStore.shared.applyFormation(formation)
        }
        presenter.present(picker, animated: true)
    }

    private func presentPitchOptions(from presenter: UIViewController?) {
        guard let presenter else { return }
        let sheet = PitchOptionsViewController(options: LineupStore.shared.pitchDisplayOptions)
        sheet.onSave = { options in
            LineupStore.shared.pitchDisplayOptions = options
            (presenter as? LineupEditorViewController)?.refreshPitchAndLineOptions()
        }
        presenter.present(sheet, animated: true)
    }

    private func presentLineOptions(from presenter: UIViewController?) {
        guard let presenter else { return }
        let sheet = LineOptionsViewController()
        sheet.invoke(viewModel: LineOptionsViewModel(options: LineupStore.shared.tacticalLineOptions))
        sheet.onSave = { options in
            LineupStore.shared.tacticalLineOptions = options
            (presenter as? LineupEditorViewController)?.refreshPitchAndLineOptions()
        }
        presenter.present(sheet, animated: true)
    }

    private func pushPlayerPicker(slot: Int, from presenter: UIViewController?) {
        let vc = PlayerPickerViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.invoke(viewModel: PlayerPickerViewModel(slotIndex: slot))
        navigate(to: .push(vc))
    }

    private func pushBenchPlayerPicker(benchIndex: Int, from presenter: UIViewController?) {
        let vc = PlayerPickerViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.invoke(viewModel: PlayerPickerViewModel(slotIndex: benchIndex) { player in
            LineupStore.shared.setBenchPlayer(player, at: benchIndex)
        })
        navigate(to: .push(vc))
    }
}
