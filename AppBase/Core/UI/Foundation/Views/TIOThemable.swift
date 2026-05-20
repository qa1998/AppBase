//
//  TIOThemable.swift
//  AppBase
//

import UIKit

/// Common views implement `applyTheme` và gọi `startTheming()` trong `commonInit`.
protocol TIOThemable: AnyObject {
    func applyTheme(_ colors: ThemeColors)
    func startTheming()
}

extension TIOThemable where Self: UIView {

    func startTheming() {
        bindTheme { [weak self] colors in
            self?.applyTheme(colors)
        }
    }
}
