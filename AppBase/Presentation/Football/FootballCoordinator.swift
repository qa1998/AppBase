//
//  FootballCoordinator.swift
//  AppBase
//

import BaseMVVM
import UIKit

/// Root coordinator for Football Lineup Builder (app main flow).
final class FootballCoordinator: Coordinator<VoidMeta> {

    enum EntryPoint {
        case splash
        case tabs
    }

    private let entryPoint: EntryPoint
    private let rootContainer: UINavigationController
    private var tabController: FootballTabBarController?

    private lazy var lineupsNav: UINavigationController = makeNav()
    private lazy var matchesNav: UINavigationController = makeNav()
    private lazy var settingsNav: UINavigationController = makeNav()

    init(entryPoint: EntryPoint = .splash) {
        self.entryPoint = entryPoint
        rootContainer = UINavigationController()
        super.init()
        rootContainer.setNavigationBarHidden(true, animated: false)
        rootContainer.navigationBar.prefersLargeTitles = false
    }

    override var rootViewController: UIViewController {
        rootContainer
    }

    override func start() {
        super.start()
        switch entryPoint {
        case .splash:
            showSplash()
        case .tabs:
            showMainTabs(animated: false)
        }
    }

    // MARK: - Flow

    private func showSplash() {
        let vc = FootballSplashViewController()
        let vm = FootballSplashViewModel()
        vc.invoke(viewModel: vm)
        vc.onSplashFinished = { [weak self] in
            self?.showMainTabs(animated: true)
        }
        rootContainer.setViewControllers([vc], animated: false)
    }

    private func showMainTabs(animated: Bool) {
        let tab = FootballTabBarController()
        tabController = tab

        lineupsNav.setViewControllers([makeLineupsScreen()], animated: false)
        matchesNav.setViewControllers([makeMatchesScreen()], animated: false)
        settingsNav.setViewControllers([makeSettingsScreen()], animated: false)

        lineupsNav.tabBarItem = UITabBarItem(
            title: L10n.Football.Tab.lineups,
            image: UIImage(systemName: "sportscourt.fill"),
            tag: 0
        )
        matchesNav.tabBarItem = UITabBarItem(
            title: L10n.Football.Tab.matches,
            image: UIImage(systemName: "soccerball"),
            tag: 1
        )
        settingsNav.tabBarItem = UITabBarItem(
            title: L10n.Football.Tab.settings,
            image: UIImage(systemName: "gearshape.fill"),
            tag: 2
        )

        tab.viewControllers = [lineupsNav, matchesNav, settingsNav]
        [lineupsNav, matchesNav, settingsNav].forEach { $0.delegate = tab }
        rootContainer.setViewControllers([tab], animated: animated)
    }

    private func makeLineupsScreen() -> UIViewController {
        let vc = MyLineupsViewController()
        let vm = MyLineupsViewModel()
        vc.invoke(viewModel: vm)
        vc.onCreateLineup = { [weak self] in
            self?.pushEditor(animated: true)
        }
        vc.onOpenLineup = { [weak self] _ in
            self?.pushEditor(animated: true)
        }
        vc.onPremiumTap = { [weak vc] in
            guard let lineups = vc as? MyLineupsViewController else { return }
            lineups.showPremiumHint()
        }
        return vc
    }

    private func makeMatchesScreen() -> UIViewController {
        let vc = FootballMatchesViewController()
        vc.invoke(viewModel: FootballMatchesViewModel())
        return vc
    }

    private func makeSettingsScreen() -> UIViewController {
        let vc = FootballSettingsViewController()
        vc.invoke(viewModel: FootballSettingsViewModel())
        return vc
    }

    private func pushEditor(animated: Bool) {
        if lineupsNav.topViewController is LineupEditorViewController {
            return
        }
        if lineupsNav.viewControllers.count > 1 {
            lineupsNav.popToRootViewController(animated: false)
        }
        let vc = LineupEditorViewController()
        vc.hidesBottomBarWhenPushed = true
        let vm = LineupEditorViewModel()
        vc.invoke(viewModel: vm)
        wireEditor(vc)
        lineupsNav.pushViewController(vc, animated: animated)
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
        lineupsNav.setNavigationBarHidden(true, animated: false)
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
        guard let nav = presenter?.navigationController else { return }
        let vc = PlayerPickerViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.invoke(viewModel: PlayerPickerViewModel(slotIndex: slot))
        nav.pushViewController(vc, animated: true)
    }

    private func pushTactics(from presenter: UIViewController?) {
        guard let nav = presenter?.navigationController else { return }
        let vc = TacticalModeViewController()
        vc.invoke(viewModel: LineupEditorViewModel())
        nav.pushViewController(vc, animated: true)
    }

    private func makeNav() -> UINavigationController {
        let nav = UINavigationController()
        nav.navigationBar.prefersLargeTitles = false
        nav.applyFootballNavigationChrome()
        return nav
    }
}

// MARK: - Navigation chrome

extension UINavigationController {

    func applyFootballNavigationChrome() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = FootballPalette.surface.withAlphaComponent(0.65)
        appearance.titleTextAttributes = [
            .foregroundColor: FootballPalette.textPrimary,
            .font: FootballPalette.title(17),
        ]
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.tintColor = FootballPalette.accentGreen
    }
}
