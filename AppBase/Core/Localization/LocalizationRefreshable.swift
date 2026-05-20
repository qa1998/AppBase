//
//  LocalizationRefreshable.swift
//  AppBase
//

import UIKit

/// Màn UIKit cần cập nhật copy khi `LocalizationService.currentLanguage` đổi.
protocol LocalizationRefreshable: AnyObject {
    func refreshLocalization()
}

extension Notification.Name {
    static let localizationDidChange = Notification.Name("LocalizationService.localizationDidChange")
}
