//
//  SplashViewModel.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import BaseMVVM
import Foundation
class SplashViewModel: TIOViewModel {
    
    override func viewModelDidReady() {
        super.viewModelDidReady()
        DispatchQueue.main.async {
            if AppData.shared.isFirstLaunch {
                AppStateEvent.set(state: .welcome)
            } else {
                AppStateEvent.set(state: .main)
            }
        }
    }
}
