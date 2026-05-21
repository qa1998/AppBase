//
//  UIViewController+TIOAlert.swift
//  AppBase
//

import UIKit

extension UIViewController {

    func showTIOAlert(
        title: String? = L10n.Common.Error.title,
        message: String,
        primaryTitle: String = L10n.Common.ok,
        primaryHandler: (() -> Void)? = nil,
        secondaryTitle: String? = nil,
        secondaryHandler: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: primaryTitle, style: .default) { _ in
            primaryHandler?()
        })
        if let secondaryTitle {
            alert.addAction(UIAlertAction(title: secondaryTitle, style: .cancel) { _ in
                secondaryHandler?()
            })
        }
        present(alert, animated: true)
    }

    /// Retry dialog — toast lỗi dùng `TIOEntryPresenter` qua `trackError` (mặc định).
    func showTIOError(_ error: TIOUserFacingError, onRetry: (() -> Void)? = nil) {
        guard error.showsRetry, let onRetry else {
            TIOEntryPresenter.showError(error)
            return
        }
        showTIOAlert(
            title: error.title,
            message: error.message,
            primaryTitle: L10n.Common.retry,
            primaryHandler: onRetry,
            secondaryTitle: L10n.Common.cancel
        )
    }
}
