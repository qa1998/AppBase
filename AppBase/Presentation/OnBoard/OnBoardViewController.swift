//
//  OnBoardViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
import SwiftUI
import BaseMVVM

class OnBoardViewController<VM: OnBoardViewModel>: TIOScreenViewController<VM> {

    private lazy var hostingController = UIHostingController(
        rootView: OnBoardView { [weak self] in
            self?.completeOnboarding()
        }
    )

    override func setupUI() {
        super.setupUI()
        embedHostingController(hostingController)
    }

    private func completeOnboarding() {
        AppData.shared.isFirstLaunch = false
        AppStateEvent.set(state: .main)
    }
}
