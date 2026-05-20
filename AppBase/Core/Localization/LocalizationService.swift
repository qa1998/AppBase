//
//  LocalizationService.swift
//  AppBase
//
//  Created by QuangAnh on 7/5/26.
//


import Foundation
import Combine

final class LocalizationService: ObservableObject {

    static let shared = LocalizationService()

    private let languageKey = "selected_language"

    @Published private(set) var currentLanguage: Language

    private init() {
        let value = UserDefaults.standard.string(forKey: languageKey)
        currentLanguage = Language(rawValue: value ?? "en") ?? .english
    }

    func setLanguage(_ language: Language) {
        guard currentLanguage != language else { return }
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: languageKey)
        LocalizationRefresh.refreshVisibleUI()
    }
}
