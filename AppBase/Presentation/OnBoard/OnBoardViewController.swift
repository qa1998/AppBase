//
//  OnBoardViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
import SwiftUI
class OnBoardViewController: UIViewController {
    
    private lazy var hostingController = UIHostingController(
        rootView: OnBoardView { [weak self] in
            AppData.shared.isFirstLaunch = false
            AppStateEvent.set(state: .main)
        }
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
}

