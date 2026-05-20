//
//  SplashViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
import SwiftUI
import BaseMVVM

class SplashViewController<VM: SplashViewModel>: TIOScreenViewController<VM> {

    private lazy var hostingController = UIHostingController(
        rootView: SplashView()
    )

    override func setupUI() {
        super.setupUI()
        embedHostingController(hostingController)
    }
}
