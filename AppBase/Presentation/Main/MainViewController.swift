//
//  MainViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
import BaseMVVM

final class MainViewController: ESTabBarController {
    
    // MARK: - Coordinator
    
    private lazy var homeCoordinator: HomeCoordinator = {
        let coordinator = HomeCoordinator(
            navigationController: UINavigationController()
        )
        
        coordinator.start()
        
        return coordinator
    }()
    
    private lazy var scriptCoordinator: ScriptCoordinator = {
        let coordinator = ScriptCoordinator(
            navigationController: UINavigationController()
        )
        coordinator.start()
        return coordinator
    }()
    
    private lazy var recordCoordinator: RecordCoordinator = {
        let coordinator = RecordCoordinator(
            navigationController: UINavigationController()
        )
        
        coordinator.start()
        
        return coordinator
    }()
    
    private lazy var settingCoordinator: SettingCoordinator = {
        let coordinator = SettingCoordinator(
            navigationController: UINavigationController()
        )
        
        coordinator.start()
        
        return coordinator
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
        setupViewControllers()
    }
}

// MARK: - Setup

private extension MainViewController {
    
    func setupTabBar() {
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = .white
        
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.05)
        
        tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .lightGray
        
        tabBar.itemPositioning = .centered
    }
    
    func setupViewControllers() {
        
        let homeNav = homeCoordinator.navigationController
        let scriptNav = scriptCoordinator.navigationController
        let recordNav = recordCoordinator.navigationController
        let settingNav = settingCoordinator.navigationController
        
        homeNav.tabBarItem = ESTabBarItem.init(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"), tag: 0)
        scriptNav.tabBarItem = ESTabBarItem.init(title: "Scripts", image: UIImage(systemName: "doc.text"), selectedImage: UIImage(systemName: "doc.text.fill"), tag: 1)
        recordNav.tabBarItem = ESTabBarItem.init(title: "Record", image: UIImage(systemName: "mic"), selectedImage: UIImage(systemName: "mic.fill"), tag: 2)
        settingNav.tabBarItem = ESTabBarItem.init(title: "Cài đặt",image: UIImage(systemName: "gearshape"),selectedImage: UIImage(systemName: "gearshape.fill"),tag: 3)
    
        viewControllers = [
            homeNav,
            scriptNav,
            recordNav,
            settingNav
        ]
        
//        selectedIndex = 2
    }
}
