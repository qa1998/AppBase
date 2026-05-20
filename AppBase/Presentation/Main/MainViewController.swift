//
//  MainViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
import BaseMVVM
import Combine

class MainViewController: ESTabBarController {

    private var themeCancel: AnyCancellable?
    private var localizationCancel: AnyCancellable?

    var homeCoor: Coordinator = {
        let nav = UINavigationController()
        let homeCoor = HomeCoordinator(navigationController: nav)
        homeCoor.start()
        return homeCoor
    }()

    var scriptsCoor: Coordinator = {
        let nav = UINavigationController()
        let scriptsCoor = ScriptsCoordinator(navigationController: nav)
        scriptsCoor.start()
        return scriptsCoor
    }()

    var recordCoor: Coordinator = {
        let nav = UINavigationController()
        let recordCoor = RecordCoordinator(navigationController: nav)
        recordCoor.start()
        return recordCoor
    }()

    var libraryCoor: Coordinator = {
        let nav = UINavigationController()
        let libraryCoor = LibraryCoordinator(navigationController: nav)
        libraryCoor.start()
        return libraryCoor
    }()

    var settingCoor: Coordinator = {
        let nav = UINavigationController()
        let settingCoor = SettingCoordinator(navigationController: nav)
        settingCoor.start()
        return settingCoor
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindThemeUpdates()
        bindLocalizationUpdates()

        viewControllers = [
            homeCoor.rootViewController,
            scriptsCoor.rootViewController,
            recordCoor.rootViewController,
            libraryCoor.rootViewController,
            settingCoor.rootViewController
        ]

        applyTabBarItems()
        applyTabBarTheme()
    }

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
        let configs: [(Coordinator, String, String, Int)] = [
            (homeCoor, L10n.Tab.home, "house.fill", 0),
            (scriptsCoor, L10n.Tab.scripts, "doc.text.fill", 1),
            (recordCoor, L10n.Tab.record, "record.circle.fill", 2),
            (libraryCoor, L10n.Tab.library, "folder.fill", 3),
            (settingCoor, L10n.Tab.settings, "gearshape.fill", 4)
        ]

        let titles = configs.map(\.1)

        for (coordinator, title, imageName, tag) in configs {
            coordinator.rootViewController.tabBarItem = makeTabBarItem(
                title: title,
                imageName: imageName,
                tag: tag
            )
        }

        ESTabBarAppearance.updateTitles(on: tabBar, titles: titles)
    }

    private func makeTabBarItem(title: String, imageName: String, tag: Int) -> ESTabBarItem {
        ESTabBarItem(
            title: title,
            image: UIImage(systemName: imageName),
            tag: tag
        )
    }

    private func applyTabBarTheme() {
        let colors = ThemeManager.shared.palette
        TabBarAppearance().apply(to: tabBar)
        ESTabBarAppearance.apply(to: tabBar, colors: colors)
    }
}
