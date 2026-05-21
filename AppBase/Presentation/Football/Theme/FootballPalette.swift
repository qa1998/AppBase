//
//  FootballPalette.swift
//  AppBase
//

import UIKit

struct FootballColors {
    let background: UIColor
    let surface: UIColor
    let surfaceElevated: UIColor
    let pitchGreen: UIColor
    let pitchLine: UIColor
    let accentGreen: UIColor
    let accentRed: UIColor
    let textPrimary: UIColor
    let textSecondary: UIColor
    let glassBorder: UIColor
    let neonGlowGreen: UIColor
    let neonGlowRed: UIColor

    static let dark = FootballColors(
        background: UIColor(hex: 0x0F1115),
        surface: UIColor(hex: 0x161B22),
        surfaceElevated: UIColor(hex: 0x1C2129),
        pitchGreen: UIColor(hex: 0x1A3D2E),
        pitchLine: UIColor.white.withAlphaComponent(0.85),
        accentGreen: UIColor(hex: 0x00D26A),
        accentRed: UIColor(hex: 0xFF2D55),
        textPrimary: .white,
        textSecondary: UIColor(hex: 0x8B949E),
        glassBorder: UIColor.white.withAlphaComponent(0.12),
        neonGlowGreen: UIColor(hex: 0x00D26A, alpha: 0.45),
        neonGlowRed: UIColor(hex: 0xFF2D55, alpha: 0.35)
    )

    static let light = FootballColors(
        background: UIColor(hex: 0xF2F4F7),
        surface: UIColor(hex: 0xFFFFFF),
        surfaceElevated: UIColor(hex: 0xE8ECF1),
        pitchGreen: UIColor(hex: 0x3D8B63),
        pitchLine: UIColor.white.withAlphaComponent(0.9),
        accentGreen: UIColor(hex: 0x00A855),
        accentRed: UIColor(hex: 0xE5194B),
        textPrimary: UIColor(hex: 0x0F1115),
        textSecondary: UIColor(hex: 0x57606A),
        glassBorder: UIColor.black.withAlphaComponent(0.08),
        neonGlowGreen: UIColor(hex: 0x00A855, alpha: 0.35),
        neonGlowRed: UIColor(hex: 0xE5194B, alpha: 0.28)
    )

    static func resolved(for mode: ThemeMode) -> FootballColors {
        mode == .light ? .light : .dark
    }
}

/// Premium tactical board palette — resolves for dark / light via `ThemeManager`.
enum FootballPalette {

    private static var colors: FootballColors {
        FootballColors.resolved(for: ThemeManager.shared.mode)
    }

    static var background: UIColor { colors.background }
    static var surface: UIColor { colors.surface }
    static var surfaceElevated: UIColor { colors.surfaceElevated }
    static var pitchGreen: UIColor { colors.pitchGreen }
    static var pitchLine: UIColor { colors.pitchLine }
    static var accentGreen: UIColor { colors.accentGreen }
    static var accentRed: UIColor { colors.accentRed }
    static var textPrimary: UIColor { colors.textPrimary }
    static var textSecondary: UIColor { colors.textSecondary }
    static var glassBorder: UIColor { colors.glassBorder }
    static var neonGlowGreen: UIColor { colors.neonGlowGreen }
    static var neonGlowRed: UIColor { colors.neonGlowRed }

    static func headline(_ size: CGFloat = 28) -> UIFont {
        .systemFont(ofSize: size, weight: .bold)
    }

    static func title(_ size: CGFloat = 20) -> UIFont {
        .systemFont(ofSize: size, weight: .semibold)
    }

    static func body(_ size: CGFloat = 15) -> UIFont {
        .systemFont(ofSize: size, weight: .regular)
    }

    static func caption(_ size: CGFloat = 12) -> UIFont {
        .systemFont(ofSize: size, weight: .medium)
    }
}

extension Notification.Name {
    static let footballThemeDidChange = Notification.Name("FootballAppearance.themeDidChange")
}

enum FootballAppearance {

    static func applyWindowStyle(for mode: ThemeMode) {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .forEach { window in
                switch mode {
                case .light:
                    window.overrideUserInterfaceStyle = .light
                case .dark:
                    window.overrideUserInterfaceStyle = .dark
                case .system:
                    window.overrideUserInterfaceStyle = .unspecified
                }
            }
        NotificationCenter.default.post(name: .footballThemeDidChange, object: nil)
    }

    static func syncFromThemeManager() {
        applyWindowStyle(for: ThemeManager.shared.mode)
    }
}

extension UIColor {

    convenience init(hex: Int, alpha: CGFloat = 1) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >> 8) & 0xFF) / 255
        let b = CGFloat(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
