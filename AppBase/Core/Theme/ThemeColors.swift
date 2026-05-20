//
//  ThemeColors.swift
//  AppBase
//

import UIKit

struct ThemeColors: Equatable {

    let backgroundPrimary: UIColor
    let backgroundSecondary: UIColor
    let textPrimary: UIColor
    let textSecondary: UIColor
    let primary: UIColor
    let error: UIColor
    let separator: UIColor

    static func == (lhs: ThemeColors, rhs: ThemeColors) -> Bool {
        lhs.backgroundPrimary == rhs.backgroundPrimary
            && lhs.backgroundSecondary == rhs.backgroundSecondary
            && lhs.textPrimary == rhs.textPrimary
            && lhs.textSecondary == rhs.textSecondary
            && lhs.primary == rhs.primary
            && lhs.error == rhs.error
            && lhs.separator == rhs.separator
    }
}

extension ThemeColors {

    static let light = ThemeColors(
        backgroundPrimary: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
        backgroundSecondary: UIColor(red: 0.949, green: 0.949, blue: 0.969, alpha: 1),
        textPrimary: UIColor(red: 0, green: 0, blue: 0, alpha: 1),
        textSecondary: UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 0.6),
        primary: UIColor(red: 0, green: 0.478, blue: 1, alpha: 1),
        error: UIColor(red: 1, green: 0.231, blue: 0.188, alpha: 1),
        separator: UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 0.36)
    )

    static let dark = ThemeColors(
        backgroundPrimary: UIColor(red: 0.11, green: 0.11, blue: 0.118, alpha: 1),
        backgroundSecondary: UIColor(red: 0, green: 0, blue: 0, alpha: 1),
        textPrimary: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
        textSecondary: UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1),
        primary: UIColor(red: 0.039, green: 0.518, blue: 1, alpha: 1),
        error: UIColor(red: 1, green: 0.27, blue: 0.23, alpha: 1),
        separator: UIColor(red: 0.329, green: 0.329, blue: 0.345, alpha: 0.65)
    )
}
