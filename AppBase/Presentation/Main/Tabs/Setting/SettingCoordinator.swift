//
//  SettingCoordinator.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
import BaseMVVM
class SettingCoordinator: NavigationCoordinator<VoidMeta> {
    private lazy var rootVC: UIViewController = {
        let vc = SettingViewController()
        let vm = SettingViewModel()
        vc.invoke(viewModel: vm)
        return vc
    }()
    
    override func start() {
        super.start()
        self.navigate(to: .set([rootVC]), transitioning: .none)
    }
}
