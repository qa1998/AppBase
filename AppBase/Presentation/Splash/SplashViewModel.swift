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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            AppStateEvent.set(state: .main)
        }
    }
}
