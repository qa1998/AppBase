//
//  AppEnvironment.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//


enum AppEnvironment {
    
    case development
    case staging
    case production
    
    static var current: AppEnvironment {
        return .development
    }
}
