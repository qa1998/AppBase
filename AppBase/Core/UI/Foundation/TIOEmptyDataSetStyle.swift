//
//  TIOEmptyDataSetStyle.swift
//  AppBase
//

import UIKit

enum TIOEmptyDataSetStyle {

    static func title(_ text: String) -> NSAttributedString {
        attributed(
            text,
            font: Font.bold(size: .text22),
            color: ThemeManager.shared.palette.textPrimary
        )
    }

    static func description(_ text: String) -> NSAttributedString {
        attributed(
            text,
            font: Font.default(size: .text17),
            color: ThemeManager.shared.palette.textSecondary
        )
    }

    static func buttonTitle(_ text: String) -> NSAttributedString {
        attributed(
            text,
            font: Font.bold(size: .buttons),
            color: ThemeManager.shared.palette.primary
        )
    }

    private static func attributed(_ text: String, font: UIFont, color: UIColor) -> NSAttributedString {
        NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: color
            ]
        )
    }
}
