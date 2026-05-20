//
//  TIOView.swift
//  AppBase
//

import UIKit

/// Base UIView — shimmer + theme tự cập nhật khi `ThemeManager.palette` đổi.
class TIOView: UIView, ShimmeringViewProtocol, TIOThemable {

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
        startTheming()
    }

    func applyTheme(_ colors: ThemeColors) {
        // Subclasses override; mặc định giữ clear.
    }
}
