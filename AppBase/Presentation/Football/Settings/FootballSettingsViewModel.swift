//
//  FootballSettingsViewModel.swift
//  AppBase
//

import Combine
import Foundation

final class FootballSettingsViewModel: TIOViewModel<TIOLoadingTarget> {

    @Published private(set) var themeMode: ThemeMode
    @Published private(set) var currentLanguage: Language

    override init() {
        let mode = ThemeManager.shared.mode
        themeMode = mode == .light ? .light : .dark
        currentLanguage = LocalizationService.shared.currentLanguage
        super.init()
    }

    func selectLanguage(_ language: Language) {
        guard currentLanguage != language else { return }
        LocalizationService.shared.setLanguage(language)
        currentLanguage = language
    }

    var appVersionText: String {
        let version = AppData.appVersion
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""
        guard !build.isEmpty else { return version }
        return "\(version) (\(build))"
    }

    func selectDarkMode() {
        applyTheme(.dark)
    }

    func selectLightMode() {
        applyTheme(.light)
    }

    func clearFootballData() {
        FootballDataClearService.clearAllFootballData()
        presentSuccess(L10n.Football.Settings.clearDataSuccess)
    }

    var isDarkSelected: Bool { themeMode == .dark }
    var isLightSelected: Bool { themeMode == .light }

    private func applyTheme(_ mode: ThemeMode) {
        guard themeMode != mode else { return }
        themeMode = mode
        ThemeManager.shared.mode = mode
        FootballAppearance.applyWindowStyle(for: mode)
    }
}
