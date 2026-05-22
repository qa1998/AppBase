//
//  TrackError.swift
//  AppBase
//

import Foundation

/// Lỗi hiển thị cho user — `trackError` → SwiftEntryKit (toast top).
struct TIOUserFacingError: Error {

    let title: String?
    let message: String
    let showsRetry: Bool

    init(title: String? = L10n.Common.Error.title, message: String, showsRetry: Bool = false) {
        self.title = title
        self.message = message
        self.showsRetry = showsRetry
    }

    static var generic: TIOUserFacingError {
        TIOUserFacingError(message: L10n.Common.Error.message)
    }
    static var empty: TIOUserFacingError {
        TIOUserFacingError(message: L10n.Football.Editor.importTeamEmpty)
    }
    static func listLoadFailed(message: String? = nil) -> TIOUserFacingError {
        TIOUserFacingError(
            title: L10n.List.Error.title,
            message: message ?? L10n.List.Error.message,
            showsRetry: false
        )
    }
}

/// Thành công — `trackSuccess` → SwiftEntryKit (toast top).
struct TIOSuccessMessage: Equatable {

    let title: String?
    let message: String

    init(title: String? = nil, message: String) {
        self.title = title
        self.message = message
    }
}
