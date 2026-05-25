//
//  LocalizationRefreshable.swift
//  AppBase
//

import UIKit

/// Màn UIKit cần cập nhật copy khi `LocalizationService.currentLanguage` đổi.
protocol LocalizationRefreshable: AnyObject {
    func refreshLocalization()
}

/// Custom large title / `navSetting` — refresh độc lập vì nhiều màn override `refreshLocalization` không gọi `super`.
protocol NavigationLocalizationRefresh: AnyObject {
    func refreshNavigationLocalization()
}

extension Notification.Name {
    static let localizationDidChange = Notification.Name("LocalizationService.localizationDidChange")
}
