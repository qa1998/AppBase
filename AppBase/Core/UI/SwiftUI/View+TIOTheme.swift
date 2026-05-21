//
//  View+TIOTheme.swift
//  AppBase
//

import SwiftUI

extension View {

    /// Nền màn SwiftUI theo `ThemeManager.palette.backgroundSecondary`.
    func tioScreenBackground() -> some View {
        modifier(TIOScreenBackgroundModifier())
    }

    /// Rebuild view khi đổi ngôn ngữ (gắn `.id` theo `LocalizationService`).
    func tioLocalizationAware() -> some View {
        modifier(TIOLocalizationAwareModifier())
    }
}

private struct TIOScreenBackgroundModifier: ViewModifier {

    @ObservedObject private var themeManager = ThemeManager.shared

    func body(content: Content) -> some View {
        content
            .background(Color(uiColor: themeManager.palette.backgroundSecondary))
    }
}

private struct TIOLocalizationAwareModifier: ViewModifier {

    @ObservedObject private var localization = LocalizationService.shared

    func body(content: Content) -> some View {
        content.id(localization.currentLanguage.rawValue)
    }
}
