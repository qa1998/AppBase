//
//  LocalizationService.swift
//  AppBase
//
//  Created by QuangAnh on 7/5/26.
//


import Foundation

final class LocalizationService {
    
    static let shared = LocalizationService()
    
    private init() {}
    
    private let languageKey = "selected_language"
    
    var currentLanguage: Language {
        
        get {
            
            let value = UserDefaults.standard.string(
                forKey: languageKey
            )
            
            return Language(
                rawValue: value ?? "en"
            ) ?? .english
        }
        
        set {
            
            UserDefaults.standard.set(
                newValue.rawValue,
                forKey: languageKey
            )
        }
    }
    
    func setLanguage(
        _ language: Language
    ) {
        
        currentLanguage = language
    }
}
