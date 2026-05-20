//
//  TIOView.swift
//  AppBase
//

import UIKit

/// Base UIView — hỗ trợ shimmer qua `ShimmeringViewProtocol`.
class TIOView: UIView, ShimmeringViewProtocol {

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
        backgroundColor = .clear
    }
}
