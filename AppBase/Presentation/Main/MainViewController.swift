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
    var settingCoor: Coordinator = {
        let nav = UINavigationController()
        let settingCoor = SettingCoordinator(navigationController: nav)
        settingCoor.start()
        return settingCoor
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.viewControllers = [
                self.homeCoor.rootViewController,
                self.settingCoor.rootViewController
            ]
        }
        
    }
}

