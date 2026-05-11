//
//  Font.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit

enum Font {
    static func `default`(size: FontSize) -> UIFont {
        return UIFont(name: "Lato-Regular", size: size.value) ?? .systemFont(ofSize: size.value)
    }
    static func bold(size: FontSize) -> UIFont {
        return UIFont(name: "Lato-Bold", size: size.value) ?? .systemFont(ofSize: size.value)
    }
    static func italic(size: FontSize) -> UIFont {
        return UIFont(name: "Lato-Italic", size: size.value) ?? .systemFont(ofSize: size.value)
    }
}
