//
//  ThemeColors.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit

struct ThemeColors {
    
    let backgroundPrimary: UIColor
    let backgroundSecondary: UIColor
    let textPrimary: UIColor
    let textSecondary: UIColor
    let primary: UIColor
    let error: UIColor
    let separator: UIColor
}

extension ThemeColors {
    static let light = ThemeColors(
        backgroundPrimary: .white,
        backgroundSecondary: .systemBackground,
        textPrimary: .label,
        textSecondary: .secondaryLabel,
        primary: .systemBlue,
        error: .systemRed,
        separator: .separator)
    
    static let dark = ThemeColors(
        backgroundPrimary: .white,
        backgroundSecondary: .systemBackground,
        textPrimary: .label,
        textSecondary: .secondaryLabel,
        primary: .systemBlue,
        error: .systemRed,
        separator: .separator)
}
