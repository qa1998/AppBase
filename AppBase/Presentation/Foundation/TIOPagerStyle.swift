//
//  TIOPagerStyle.swift
//  AppBase
//

import JXSegmentedView
import UIKit

/// UI config cho `TIOPagerViewController` (JXSegmentedView).
struct TIOPagerStyle: Equatable {

    var barHeight: CGFloat = 44
    var contentEdgeInsetLeft: CGFloat = 16
    var contentEdgeInsetRight: CGFloat = 16
    var itemSpacing: CGFloat = 20
    var isItemSpacingAverageEnabled: Bool = true

    var titleFont: UIFont = .systemFont(ofSize: 15, weight: .medium)
    var selectedTitleFont: UIFont = .systemFont(ofSize: 15, weight: .semibold)
    var titleColor: UIColor? = nil
    var selectedTitleColor: UIColor? = nil
    var isTitleColorGradientEnabled: Bool = true

    var showsIndicatorLine: Bool = true
    var indicatorLineHeight: CGFloat = 3
    var indicatorColor: UIColor? = nil
    var indicatorWidth: CGFloat = JXSegmentedViewAutomaticDimension

    var barBackgroundColor: UIColor? = nil
    var contentBackgroundColor: UIColor? = nil

    static let `default` = TIOPagerStyle()
}

