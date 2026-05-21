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
        navigationController.setNavigationBarHidden(true, animated: false)
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
        let sheet = LineOptionsViewController(options: LineupStore.shared.tacticalLineOptions)
        sheet.onSave = { options in
            LineupStore.shared.tacticalLineOptions = options
            (presenter as? LineupEditorViewController)?.refreshPitchAndLineOptions()
        }
        presenter.present(sheet, animated: true)
    }

    private func pushPlayerPicker(slot: Int, from presenter: UIViewController?) {
        let vc = PlayerPickerViewController()

        vc.invoke(viewModel: PlayerPickerViewModel(slotIndex: slot))
        self.navigate(to: .push(vc))
    }
}
