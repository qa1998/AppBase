//
//  TrackableUseCaseBindable.swift
//  AppBase
//

import Combine
import Foundation

/// UseCase gắn `TIOViewModel.bindUseCase`.
protocol TrackableUseCaseBindable: AnyObject {

    associatedtype Output

    var isLoading: CurrentValueSubject<Bool, Never> { get }
    var didSucceed: PassthroughSubject<Output, Never> { get }
    var didFail: PassthroughSubject<TIOUserFacingError, Never> { get }

    /// Từ `Input` lần `run` gần nhất — đọc trong `bindUseCase`.
    var pendingSuccessToastMessage: String? { get }
    var pendingShowsErrorToast: Bool { get }

    func clearPendingSuccessToast()
}
