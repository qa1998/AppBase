//
//  Font+SwiftUI.swift
//  AppBase
//

import SwiftUI
import UIKit

extension Font {

    enum Style {
        case regular
        case bold
        case italic
    }

    /// SwiftUI `Font` from Lato via `Font.default` / `bold` / `italic`.
    static func swiftUIFont(_ size: FontSize, style: Style = .regular) -> SwiftUI.Font {
        let uiFont: UIFont
        switch style {
        case .regular:
            uiFont = `default`(size: size)
        case .bold:
            uiFont = bold(size: size)
        case .italic:
            uiFont = italic(size: size)
        }
        return SwiftUI.Font(uiFont)
    }
}
