//
//  ThemeManager.swift
//  AppBase
//

import UIKit
import Combine

extension Notification.Name {
    static let themeDidChange = Notification.Name("ThemeManager.themeDidChange")
}

final class ThemeManager: ObservableObject {

    static let shared = ThemeManager()

    @Published var mode: ThemeMode {
        didSet {
            save()
            applyWindowStyle()
            updatePalette()
        }
    }

    @Published private(set) var palette: ThemeColors

    /// Alias — dùng `palette` hoặc `colors` đều được.
    var colors: ThemeColors { palette }

    private init() {
        let initialMode = ThemeMode(
            rawValue: UserDefaults.standard.string(forKey: "theme_mode") ?? ""
        ) ?? .system
        mode = initialMode
        palette = ThemeManager.resolveColors(for: initialMode)
        applyWindowStyle()
    }

    func apply() {
        applyWindowStyle()
        updatePalette()
    }

    /// Gọi khi `traitCollection` đổi (mode `.system`) để refresh palette + UI.
    func refreshPaletteIfNeeded() {
        guard mode == .system else { return }
        updatePalette()
    }
}

// MARK: - Window

extension ThemeManager {

    func applyWindowStyle() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        windowScene.windows.forEach { window in
            switch mode {
            case .system:
                window.overrideUserInterfaceStyle = .unspecified
            case .light:
                window.overrideUserInterfaceStyle = .light
            case .dark:
                window.overrideUserInterfaceStyle = .dark
            }
        }
    }

    func updatePalette() {
        let resolved = ThemeManager.resolveColors(for: mode)
        guard resolved != palette else {
            AppAppearance.shared.applyIncludingVisibleBars()
            return
        }
        palette = resolved
        AppAppearance.shared.applyIncludingVisibleBars()
        NotificationCenter.default.post(name: .themeDidChange, object: self)
    }
}

// MARK: - Resolve

private extension ThemeManager {

    static func resolveColors(for mode: ThemeMode) -> ThemeColors {
        switch mode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            let style = UIScreen.main.traitCollection.userInterfaceStyle
            return style == .dark ? .dark : .light
        }
    }

    func save() {
        UserDefaults.standard.set(mode.rawValue, forKey: "theme_mode")
    }
}
