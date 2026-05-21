//
//  FootballSettingsViewModel.swift
//  AppBase
//

import Combine
import Foundation

final class FootballSettingsViewModel: TIOViewModel<TIOLoadingTarget> {

    @Published private(set) var themeMode: ThemeMode

    override init() {
        let mode = ThemeManager.shared.mode
        themeMode = mode == .light ? .light : .dark
        super.init()
    }

    func selectDarkMode() {
        applyTheme(.dark)
    }

    func selectLightMode() {
        applyTheme(.light)
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
