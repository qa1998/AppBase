//
//  ESTabBarAppearance.swift
//  AppBase
//

import UIKit

/// ESTabBar dùng `ESTabBarItemContentView` — không theo `UITabBar.appearance()`, cần set màu trực tiếp.
enum ESTabBarAppearance {

    static func apply(to tabBar: UITabBar, colors: ThemeColors) {
        tabBar.barTintColor = colors.backgroundPrimary
        tabBar.backgroundColor = colors.backgroundPrimary

        for contentView in tabBar.findSubviews(of: ESTabBarItemContentView.self) {
            contentView.textColor = colors.textSecondary
            contentView.highlightTextColor = colors.primary
            contentView.iconColor = colors.textSecondary
            contentView.highlightIconColor = colors.primary
            contentView.updateDisplay()
        }
    }

    /// Cập nhật title tab (ESTabBarItem + UITabBarItem).
    static func updateTitles(on tabBar: UITabBar, titles: [String]) {
        guard let items = tabBar.items else { return }

        for (index, title) in titles.enumerated() where index < items.count {
            items[index].title = title
            if let item = items[index] as? ESTabBarItem {
                item.contentView.title = title
                item.contentView.updateDisplay()
            }
        }

        tabBar.setNeedsLayout()
        tabBar.layoutIfNeeded()
    }
}

private extension UIView {

    func findSubviews<T: UIView>(of type: T.Type) -> [T] {
        var result: [T] = []
        if let match = self as? T {
            result.append(match)
        }
        for subview in subviews {
            result.append(contentsOf: subview.findSubviews(of: type))
        }
        return result
    }
}
