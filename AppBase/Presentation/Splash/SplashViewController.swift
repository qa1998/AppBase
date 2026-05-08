//
//  SplashViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            AppStateEvent.set(state: .main)
        }
    }
}
