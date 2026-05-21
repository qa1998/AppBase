//
//  UIView+TIOShimmer.swift
//  AppBase
//

import UIKit

private final class TIOShimmerContentState {
    var labelTextColor: UIColor?
    var buttonTitleColors: [UInt: UIColor] = [:]
}

private var tioShimmerContentStateKey: UInt8 = 0

extension UIView {

    /// Shimmer / skeleton theo `ThemeManager.palette` (template + gradient).
    /// Ẩn chữ / title lúc loading — chỉ thấy khối skeleton (giống list cell).
    func applyTIOShimmer(_ isLoading: Bool, palette: ThemeColors = ThemeManager.shared.palette) {
        tio_setShimmerContentHidden(isLoading)

        guard isLoading else {
            setTemplateWithSubviews(false)
            return
        }
        setTemplateWithSubviews(false)
        setTemplateWithSubviews(
            true,
            color: palette.shimmerTemplateColor(for: self),
            viewBackgroundColor: palette.shimmerAnimationBackground(for: self)
        )
    }
}

// MARK: - Ẩn nội dung khi skeleton

private extension UIView {

    var tio_shimmerContentState: TIOShimmerContentState? {
        get { objc_getAssociatedObject(self, &tioShimmerContentStateKey) as? TIOShimmerContentState }
        set { objc_setAssociatedObject(self, &tioShimmerContentStateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func tio_setShimmerContentHidden(_ hidden: Bool) {
        if let label = self as? UILabel, !(self is UIButton) {
            tio_setLabelContentHidden(hidden, label: label)
            return
        }
        if let button = self as? UIButton {
            tio_setButtonContentHidden(hidden, button: button)
        }
    }

    func tio_setLabelContentHidden(_ hidden: Bool, label: UILabel) {
        if hidden {
            let state = TIOShimmerContentState()
            state.labelTextColor = label.textColor
            tio_shimmerContentState = state
            label.textColor = .clear
            if let attributed = label.attributedText, attributed.length > 0 {
                let mutable = NSMutableAttributedString(attributedString: attributed)
                mutable.addAttribute(.foregroundColor, value: UIColor.clear, range: NSRange(location: 0, length: mutable.length))
                label.attributedText = mutable
            }
        } else {
            tio_restoreShimmerContent()
        }
    }

    func tio_setButtonContentHidden(_ hidden: Bool, button: UIButton) {
        if hidden {
            if self is TIOThemable {
                // Chỉ ẩn titleLabel — restore qua `applyTheme` + bật lại alpha.
                tio_shimmerContentState = TIOShimmerContentState()
            } else {
                let state = TIOShimmerContentState()
                let states: [UIControl.State] = [.normal, .highlighted, .disabled, .selected]
                for controlState in states {
                    if let color = button.titleColor(for: controlState) {
                        state.buttonTitleColors[controlState.rawValue] = color
                    }
                }
                tio_shimmerContentState = state
                states.forEach { button.setTitleColor(.clear, for: $0) }
            }
            button.titleLabel?.alpha = 0
            button.imageView?.alpha = 0
        } else {
            tio_restoreShimmerContent()
        }
    }

    func tio_restoreShimmerContent() {
        defer { tio_shimmerContentState = nil }

        if let button = self as? UIButton {
            button.titleLabel?.alpha = 1
            button.imageView?.alpha = 1
        }

        if let themable = self as? TIOThemable {
            themable.applyTheme(ThemeManager.shared.palette)
            return
        }

        guard let state = tio_shimmerContentState else { return }

        if let label = self as? UILabel, !(self is UIButton) {
            if let saved = state.labelTextColor {
                label.textColor = saved
            }
        }

        if let button = self as? UIButton {
            for (raw, color) in state.buttonTitleColors {
                button.setTitleColor(color, for: UIControl.State(rawValue: raw))
            }
        }
    }
}
