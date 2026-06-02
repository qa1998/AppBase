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
        vc.onPickPitchPlayer = { [weak self, weak vc] slot in
            self?.pushPlayerPicker(target: .teamPitch(slot: slot), from: vc)
        }
        vc.onPickBenchPlayer = { [weak self, weak vc] index in
            self?.pushPlayerPicker(target: .teamBench(index: index), from: vc)
        }
        vc.onSaved = { [weak vc] in
            vc?.navigationController?.popViewController(animated: true)
        }
        vc.onDeleted = { [weak vc] in
            vc?.navigationController?.popViewController(animated: true)
        }
        navigate(to: .push(vc))
    }

    private func pushPlayerPicker(
        target: PlayerPickerTarget,
        from presenter: UIViewController?
    ) {
        guard let nav = presenter?.navigationController else { return }
        let vc = PlayerPickerViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.invoke(viewModel: PlayerPickerViewModel(target: target))
        vc.onCreatePlayer = { [weak vc] in
            guard let vc, let nav = vc.navigationController else { return }
            FootballPlayerEditorRouting.pushNewPlayer(from: vc, navigationController: nav)
        }
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
        navigate(to: .present(nav), animated: true)
    }
}
