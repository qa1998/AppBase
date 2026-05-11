//
//  TIOViewModel.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import BaseMVVM
import Foundation
import Combine

class TIOViewModel: BaseViewModel {
    
    let cancelBag = Set<AnyCancellable>()
    
    open override func viewModelDidReady() {
        super.viewModelDidReady()
    }
    
    open override func viewModelWillActive() {
        super.viewModelWillActive()
    }
    
    open override func viewModelDidActive() {
        super.viewModelDidActive()
    }
    
    open override func viewModelWillInactive() {
        super.viewModelWillInactive()
    }
    
    open override func viewModelDidInactive() {
        super.viewModelDidInactive()
    }
}

