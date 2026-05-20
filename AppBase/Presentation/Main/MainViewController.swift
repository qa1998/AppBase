//
//  MainViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
import BaseMVVM
import Combine

/// Tab bar chính — coordinator từng tab chỉ khởi tạo khi user chọn tab lần đầu (lazy).
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

    private var coordinators: [Int: Coordinator<VoidMeta>] = [:]
    private var placeholderViewControllers: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        bindThemeUpdates()
        bindLocalizationUpdates()

        placeholderViewControllers = Tab.allCases.map { _ in makePlaceholderViewController() }
        viewControllers = placeholderViewControllers

        loadTab(at: Tab.home.rawValue)
        selectedIndex = Tab.home.rawValue

        applyTabBarItems()
        applyTabBarTheme()
    }

    // MARK: - Lazy tab loading

    private func loadTab(at index: Int) {
        guard coordinators[index] == nil,
              index >= 0,
              index < (viewControllers?.count ?? 0) else { return }

        let coordinator = makeCoordinator(for: index)
        coordinators[index] = coordinator

        var controllers = viewControllers ?? []
        controllers[index] = coordinator.rootViewController
        controllers[index].tabBarItem = makeTabBarItem(for: index)
        viewControllers = controllers
    }

    private func makeCoordinator(for index: Int) -> Coordinator<VoidMeta> {
        let navigationController = UINavigationController()
        switch Tab(rawValue: index) {
        case .home:
            let coordinator = HomeCoordinator(navigationController: navigationController)
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
            let coordinator = LibraryCoordinator(navigationController: navigationController)
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

    private func makePlaceholderViewController() -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = ThemeManager.shared.palette.backgroundSecondary
        return controller
    }

    // MARK: - Tab bar UI

    private func bindThemeUpdates() {
        themeCancel = ThemeManager.shared.$palette
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applyTabBarTheme()
                self?.updatePlaceholderBackgrounds()
            }
    }

    private func bindLocalizationUpdates() {
        localizationCancel = LocalizationService.shared.$currentLanguage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applyTabBarItems()
            }
    }

    private func updatePlaceholderBackgrounds() {
        let color = ThemeManager.shared.palette.backgroundSecondary
        placeholderViewControllers.forEach { $0.view.backgroundColor = color }
    }

    private func applyTabBarItems() {
        guard let controllers = viewControllers else { return }

        for index in controllers.indices {
            controllers[index].tabBarItem = makeTabBarItem(for: index)
        }
        viewControllers = controllers

        let titles = Tab.allCases.map(\.title)
        ESTabBarAppearance.updateTitles(on: tabBar, titles: titles)
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
}

// MARK: - UITabBarControllerDelegate

extension MainViewController: UITabBarControllerDelegate {

    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        guard let index = viewControllers?.firstIndex(of: viewController) else {
            return true
        }

        if coordinators[index] != nil {
            return true
        }

        loadTab(at: index)
        tabBarController.selectedIndex = index
        return false
    }
}
