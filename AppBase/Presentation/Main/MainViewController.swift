//
//  MainViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
import BaseMVVM

class MainViewController: ESTabBarController {

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
        self.viewControllers = [
            self.homeCoor.rootViewController,
            self.scriptsCoor.rootViewController,
            self.recordCoor.rootViewController,
            self.libraryCoor.rootViewController,
            self.settingCoor.rootViewController
        ]

        homeCoor.rootViewController.tabBarItem = UITabBarItem(
            title: L10n.Tab.home,
            image: UIImage(systemName: "house.fill"),
            tag: 0
        )
        scriptsCoor.rootViewController.tabBarItem = UITabBarItem(
            title: L10n.Tab.scripts,
            image: UIImage(systemName: "doc.text.fill"),
            tag: 1
        )
        recordCoor.rootViewController.tabBarItem = UITabBarItem(
            title: L10n.Tab.record,
            image: UIImage(systemName: "record.circle.fill"),
            tag: 2
        )
        libraryCoor.rootViewController.tabBarItem = UITabBarItem(
            title: L10n.Tab.library,
            image: UIImage(systemName: "folder.fill"),
            tag: 3
        )
        settingCoor.rootViewController.tabBarItem = UITabBarItem(
            title: L10n.Tab.settings,
            image: UIImage(systemName: "gearshape.fill"),
            tag: 4
        )
    }
}
