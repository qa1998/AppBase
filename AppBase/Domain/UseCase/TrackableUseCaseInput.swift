//
//  TrackableUseCaseInput.swift
//  AppBase
//

import Foundation

/// Flags mỗi lần `run` — loading, toast success/error (SwiftEntryKit).
protocol TrackableUseCaseInput {

    var showsLoading: Bool { get }
    /// `true` → sau success, `bindUseCase` có thể gọi `presentSuccess` (cần `successToastMessage`).
    var showsSuccessToast: Bool { get }
    /// `true` → khi fail và không có `onFailure`, `bindUseCase` gọi `presentError`.
    var showsErrorToast: Bool { get }
    /// Message toast success; bỏ qua nếu `showsSuccessToast == false`.
    var successToastMessage: String? { get }
}

extension TrackableUseCaseInput {

    var showsSuccessToast: Bool { false }
    var showsErrorToast: Bool { true }
    var successToastMessage: String? { nil }
}
