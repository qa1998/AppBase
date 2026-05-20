//
//  TIOButton.swift
//  AppBase
//

import UIKit

class TIOButton: UIButton, ShimmeringViewProtocol, TIOThemable {

    var shimmeringAnimatedItems: [UIView] { [self] }

    var excludedItems: Set<UIView> { [] }

    /// Khi `true`, nền button = `colors.primary`, chữ trắng (vd. CTA).
    var usesFilledPrimaryStyle = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        titleLabel?.font = Font.bold(size: .buttons)
        startTheming()
    }

    func applyTheme(_ colors: ThemeColors) {
        if usesFilledPrimaryStyle {
            backgroundColor = colors.primary
            setTitleColor(.white, for: .normal)
            tintColor = .white
        } else {
            backgroundColor = .clear
            setTitleColor(colors.primary, for: .normal)
            tintColor = colors.primary
        }
    }
}
