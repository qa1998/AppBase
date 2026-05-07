//
//  BaseViewModel.swift
//  AppBase
//
//  Created by QuangAnh on 7/5/26.
//

import Foundation

open class BaseViewModel: NSObject {
    public override init() {
        super.init()
        #if DEBUG
        print("❇️\(type(of: self)) init")
        #endif
    }
    
    open func viewModelDidReady() { }
    
    open func viewModelWillActive() { }
    
    open func viewModelDidActive() { }
    
    open func viewModelWillInactive() { }
    
    open func viewModelDidInactive() { }
    
    deinit {
        #if DEBUG
        print("✅\(type(of: self)) deinit")
        #endif
    }
}
