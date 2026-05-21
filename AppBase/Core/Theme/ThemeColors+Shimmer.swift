//
//  ThemeColors+Shimmer.swift
//  AppBase
//

import UIKit

extension ThemeColors {

    /// Màu khối skeleton (template layer) — theo palette, không dùng `ShimmerColor.Placeholder`.
    func shimmerTemplateColor(for view: UIView) -> UIColor {
        if view.tio_hasOpaqueBackgroundColor {
            return UIColor.white.withAlphaComponent(0.35)
        }
        return separator.withAlphaComponent(0.65)
    }

    /// Nền cho gradient shimmer — khớp nền view hoặc `backgroundSecondary`.
    func shimmerAnimationBackground(for view: UIView) -> UIColor {
        if let opaque = view.tio_opaqueBackgroundColor {
            return opaque
        }
        return backgroundSecondary
    }
}

private extension UIView {

    var tio_opaqueBackgroundColor: UIColor? {
        guard let backgroundColor else { return nil }
        if backgroundColor == .clear || backgroundColor.cgColor.alpha < 0.01 {
            return nil
        }
        return backgroundColor
    }

    var tio_hasOpaqueBackgroundColor: Bool {
        tio_opaqueBackgroundColor != nil
    }
}
