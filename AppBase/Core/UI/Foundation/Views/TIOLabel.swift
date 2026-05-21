//
//  TIOLabel.swift
//  AppBase
//

import UIKit

class TIOLabel: UILabel, ShimmeringViewProtocol, TIOThemable {

    var shimmeringAnimatedItems: [UIView] { [self] }

    var excludedItems: Set<UIView> { [] }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        numberOfLines = 0
        font = Font.default(size: .text17)
        startTheming()
    }

    func applyTheme(_ colors: ThemeColors) {
        textColor = colors.textPrimary
    }
}


