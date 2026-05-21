//
//  FootballTeamsCoordinator.swift
//  AppBase
//

import BaseMVVM
import UIKit

final class FootballTeamsCoordinator: FootballTabNavigationCoordinator<VoidMeta> {

    override init(navigationController: UINavigationController, tabController: FootballTabBarController) {
        super.init(navigationController: navigationController, tabController: tabController)
    }

    private lazy var rootVC: UIViewController = {
        let vc = MyTeamsViewController()
        vc.invoke(viewModel: MyTeamsViewModel())
        vc.onCreateTeam = { [weak self] in
            self?.pushTeamEditor()
        }
        vc.onOpenTeam = { [weak self] team in
            TeamStore.shared.loadTeam(team)
            self?.pushTeamEditor()
        }
        return vc
    }()

    override func start() {
        super.start()
        navigate(to: .set([rootVC]), animated: false, transitioning: nil)
    }

    private func pushTeamEditor() {
        let vc = TeamEditorViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.invoke(viewModel: TeamEditorViewModel())
        vc.onPickPlayer = { [weak self, weak vc] _, handler in
            self?.pushPlayerPicker(onPicked: handler, from: vc)
        }
        vc.onPickFormation = { [weak self, weak vc] in
            self?.presentFormationPicker(from: vc)
        }
        vc.onSaved = { [weak vc] in
            vc?.navigationController?.popViewController(animated: true)
        }
        navigate(to: .push(vc))
    }

    private func presentFormationPicker(from presenter: UIViewController?) {
        guard let presenter else { return }
        let team = TeamStore.shared.currentTeam
        let picker = FormationPickerViewController(
            selectedFormationId: team.formationId,
            playerCount: team.pitchSize.playerCount
        )
        picker.onSelect = { formation in
            TeamStore.shared.applyFormation(formation)
        }
        presenter.present(picker, animated: true)
    }

    private func pushPlayerPicker(
        onPicked: @escaping (FootballPlayer) -> Void,
        from presenter: UIViewController?
    ) {
        guard let nav = presenter?.navigationController else { return }
        let vc = PlayerPickerViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.invoke(viewModel: PlayerPickerViewModel(slotIndex: 0, onPlayerSelected: onPicked))
        nav.pushViewController(vc, animated: true)
    }

    /// Chọn đội đã lưu (tạo trận / filter).
    func presentTeamPicker(
        from presenter: UIViewController,
        onSelect: @escaping (FootballTeam) -> Void
    ) {
        let vc = TeamPickerViewController()
        let vm = TeamPickerViewModel()
        vc.invoke(viewModel: vm)
        vc.onSelect = { team in
            onSelect(team)
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.applyFootballNavigationChrome()
        presenter.present(nav, animated: true)
    }
}
