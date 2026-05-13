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
    let teleprompterBackground: UIColor
    let teleprompterPanelBackground: UIColor
    let teleprompterCardBackground: UIColor
    let teleprompterTextCurrent: UIColor
    let teleprompterTextRead: UIColor
    let teleprompterTextFuture: UIColor
    let teleprompterTextSecondary: UIColor
    let teleprompterControlTint: UIColor
    let teleprompterPlayButtonBackground: UIColor
    let teleprompterPlayButtonTint: UIColor
    let teleprompterSliderTrack: UIColor
    let teleprompterActiveAccent: UIColor
}

extension ThemeColors {
    static let light = ThemeColors(
        backgroundPrimary: .white,
        backgroundSecondary: .systemBackground,
        textPrimary: .label,
        textSecondary: .secondaryLabel,
        primary: .systemBlue,
        error: .systemRed,
        separator: .separator,
        teleprompterBackground: .black,
        teleprompterPanelBackground: UIColor(white: 0.05, alpha: 0.96),
        teleprompterCardBackground: UIColor(white: 0.12, alpha: 1),
        teleprompterTextCurrent: .white,
        teleprompterTextRead: UIColor(white: 0.72, alpha: 1),
        teleprompterTextFuture: UIColor(white: 0.48, alpha: 1),
        teleprompterTextSecondary: UIColor(white: 0.55, alpha: 1),
        teleprompterControlTint: .white,
        teleprompterPlayButtonBackground: .white,
        teleprompterPlayButtonTint: .black,
        teleprompterSliderTrack: UIColor(white: 0.28, alpha: 1),
        teleprompterActiveAccent: .systemGreen)
    
    static let dark = ThemeColors(
        backgroundPrimary: .black,
        backgroundSecondary: UIColor(white: 0.06, alpha: 1),
        textPrimary: .white,
        textSecondary: UIColor(white: 0.72, alpha: 1),
        primary: .systemBlue,
        error: .systemRed,
        separator: .separator,
        teleprompterBackground: .black,
        teleprompterPanelBackground: UIColor(white: 0.05, alpha: 0.96),
        teleprompterCardBackground: UIColor(white: 0.12, alpha: 1),
        teleprompterTextCurrent: .white,
        teleprompterTextRead: UIColor(white: 0.72, alpha: 1),
        teleprompterTextFuture: UIColor(white: 0.48, alpha: 1),
        teleprompterTextSecondary: UIColor(white: 0.55, alpha: 1),
        teleprompterControlTint: .white,
        teleprompterPlayButtonBackground: .white,
        teleprompterPlayButtonTint: .black,
        teleprompterSliderTrack: UIColor(white: 0.28, alpha: 1),
        teleprompterActiveAccent: .systemGreen)
}
