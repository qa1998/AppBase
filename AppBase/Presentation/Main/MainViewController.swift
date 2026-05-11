//
//  MainViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
class MainViewController: ESTabBarController {
    
    private var homeCoor: Coordinator = {
        let nav = UINavigationController()
        let homeCoor = HomeCoordinator(navigationController: nav)
        homeCoor.start()
        return homeCoor
    }()
    
    private var settingCoor: Coordinator = {
        let nav = UINavigationController()
        let settingCoor = SettingCoordinator(navigationController: nav)
        settingCoor.start()
        return settingCoor
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = .white
        viewControllers = [
            homeCoor.rootViewController,
            settingCoor.rootViewController
        ]
    }
}

