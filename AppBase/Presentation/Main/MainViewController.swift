//
//  MainViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
import BaseMVVM
import Combine

/// Tab bar chính — 5 tab, mỗi tab một `UINavigationController` + coordinator `start()` ngay khi mở Main.
final class MainViewController: ESTabBarController {

    private enum Tab: Int, CaseIterable {
        case home
        case scripts
        case record
        case library
        case settings

        var title: String {
            switch self {
            case .home: return L10n.Tab.home
            case .scripts: return L10n.Tab.scripts
            case .record: return L10n.Tab.record
            case .library: return L10n.Tab.library
            case .settings: return L10n.Tab.settings
            }
        }

        var iconName: String {
            switch self {
            case .home: return "house.fill"
            case .scripts: return "doc.text.fill"
            case .record: return "record.circle.fill"
            case .library: return "folder.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    private var themeCancel: AnyCancellable?
    private var localizationCancel: AnyCancellable?

    private let dependencies: AppDependencies

    private var coordinators: [Coordinator<VoidMeta>] = []
    private var navigationControllers: [UINavigationController] = []

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.dependencies = AppDependencies.make()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        bindThemeUpdates()
        bindLocalizationUpdates()

        navigationControllers = Tab.allCases.map { tab in
            let navigationController = UINavigationController()
            navigationController.tabBarItem = makeTabBarItem(for: tab.rawValue)
            return navigationController
        }

        coordinators = Tab.allCases.map { tab in
            makeCoordinator(for: tab.rawValue, navigationController: navigationControllers[tab.rawValue])
        }

        viewControllers = navigationControllers
        applyTabBarTheme()
        selectedIndex = Tab.home.rawValue
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        syncESTabBarHighlight(selectedIndex)
    }

    private func makeCoordinator(
        for index: Int,
        navigationController: UINavigationController
    ) -> Coordinator<VoidMeta> {
        switch Tab(rawValue: index) {
        case .home:
            let coordinator = HomeCoordinator(
                navigationController: navigationController,
                dependencies: dependencies
            )
            coordinator.start()
            return coordinator
        case .scripts:
            let coordinator = ScriptsCoordinator(navigationController: navigationController)
            coordinator.start()
            return coordinator
        case .record:
            let coordinator = RecordCoordinator(navigationController: navigationController)
            coordinator.start()
            return coordinator
        case .library:
            let coordinator = LibraryCoordinator(
                navigationController: navigationController,
                dependencies: dependencies
            )
            coordinator.start()
            return coordinator
        case .settings:
            let coordinator = SettingCoordinator(navigationController: navigationController)
            coordinator.start()
            return coordinator
        case .none:
            fatalError("Invalid tab index: \(index)")
        }
    }

    // MARK: - Tab bar UI

    private func bindThemeUpdates() {
        themeCancel = ThemeManager.shared.$palette
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applyTabBarTheme()
            }
    }

    private func bindLocalizationUpdates() {
        localizationCancel = LocalizationService.shared.$currentLanguage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applyTabBarItems()
            }
    }

    private func applyTabBarItems() {
        for index in navigationControllers.indices {
            navigationControllers[index].tabBarItem = makeTabBarItem(for: index)
        }
        let titles = Tab.allCases.map(\.title)
        ESTabBarAppearance.updateTitles(on: tabBar, titles: titles)
        syncESTabBarHighlight(selectedIndex)
    }

    private func makeTabBarItem(for index: Int) -> ESTabBarItem {
        guard let tab = Tab(rawValue: index) else {
            return ESTabBarItem()
        }
        return ESTabBarItem(
            title: tab.title,
            image: UIImage(systemName: tab.iconName),
            tag: index
        )
    }

    private func applyTabBarTheme() {
        let colors = ThemeManager.shared.palette
        TabBarAppearance().apply(to: tabBar)
        ESTabBarAppearance.apply(to: tabBar, colors: colors)
    }

    private func syncESTabBarHighlight(_ index: Int) {
        guard let tabBar = tabBar as? ESTabBar,
              let items = tabBar.items,
              items.indices.contains(index) else { return }

        for (idx, item) in items.enumerated() {
            guard let estItem = item as? ESTabBarItem else { continue }
            if idx == index {
                estItem.contentView.select(animated: false, completion: nil)
            } else {
                estItem.contentView.deselect(animated: false, completion: nil)
            }
        }
    }
}

// MARK: - UITabBarControllerDelegate

extension MainViewController: UITabBarControllerDelegate {

    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        guard let navigationController = viewController as? UINavigationController,
              let index = navigationControllers.firstIndex(of: navigationController) else {
            return
        }
        syncESTabBarHighlight(index)
    }
}
