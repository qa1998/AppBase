//
//  UIView+Theme.swift
//  AppBase
//

import UIKit
import Combine

private final class ThemeSubscriptionBox {
    var cancellables = Set<AnyCancellable>()
}

private var viewThemeSubscriptionKey: UInt8 = 0
private var viewControllerThemeSubscriptionKey: UInt8 = 0

private func themeSubscriptionBox(
    for object: AnyObject,
    key: UnsafeRawPointer
) -> ThemeSubscriptionBox {
    if let box = objc_getAssociatedObject(object, key) as? ThemeSubscriptionBox {
        return box
    }
    let box = ThemeSubscriptionBox()
    objc_setAssociatedObject(object, key, box, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return box
}

private func bindTheme(
    on object: AnyObject,
    key: UnsafeRawPointer,
    apply: @escaping (ThemeColors) -> Void
) {
    apply(ThemeManager.shared.palette)
    ThemeManager.shared.$palette
        .receive(on: DispatchQueue.main)
        .sink { colors in
            apply(colors)
        }
        .store(in: &themeSubscriptionBox(for: object, key: key).cancellables)
}

extension UIView {

    /// Subscribe `ThemeManager.palette` — gọi một lần sau `commonInit`.
    func bindTheme(apply: @escaping (ThemeColors) -> Void) {
        AppBase.bindTheme(on: self, key: &viewThemeSubscriptionKey, apply: apply)
    }
}

extension UIViewController {

    /// Subscribe `ThemeManager.palette` — dùng trong `TIOViewController` / màn UIKit.
    func bindTheme(apply: @escaping (ThemeColors) -> Void) {
        AppBase.bindTheme(on: self, key: &viewControllerThemeSubscriptionKey, apply: apply)
    }
}
