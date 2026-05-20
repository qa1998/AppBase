//
//  TIOButton.swift
//  AppBase
//

import UIKit

class TIOButton: UIButton, ShimmeringViewProtocol {

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
        titleLabel?.font = Font.bold(size: .buttons)
    }
}
