//
//  SettingViewController.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
import SwiftUI
import BaseMVVM

class SettingViewController<VM: SettingViewModel>: TIOScreenViewController<VM> {

    private lazy var hostingController = UIHostingController(
        rootView: SettingView()
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshLocalization()
    }

    override func setupUI() {
        super.setupUI()
        embedHostingController(hostingController)
    }

    override func refreshLocalization() {
        title = L10n.Settings.title
    }
}
