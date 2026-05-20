//
//  TIOContentView.swift
//  AppBase
//

import UIKit

/// Marker: view gắn full-screen trong `TIOViewController.layoutIFSContentViewsIfNeeded()`.
protocol IFSContentView where Self: UIView {}

/// Container layout — không tham gia shimmer (chỉ bọc subviews).
class TIOContentView: TIOView, IFSContentView {

    override var shimmeringAnimatedItems: [UIView] { [] }

    override func applyTheme(_ colors: ThemeColors) {
        backgroundColor = colors.backgroundSecondary
    }
}
