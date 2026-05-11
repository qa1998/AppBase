//
//  SettingViewController.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
import SwiftUI
class SettingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Setting"
        
        let swiftUIView = SettingView()
        
        let hostingController = UIHostingController(
            rootView: swiftUIView
        )
        
        addChild(hostingController)
        
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            hostingController.view.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            hostingController.view.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            hostingController.view.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
        
        hostingController.didMove(toParent: self)
    }
}


