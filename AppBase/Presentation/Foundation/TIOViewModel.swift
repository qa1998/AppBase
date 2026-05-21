//
//  TIOViewModel.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import BaseMVVM
import Foundation
import Combine

class TIOViewModel<Event: Hashable>: BaseViewModel {
    var cancellables = Set<AnyCancellable>()
    let trackLoading = PassthroughSubject<TrackLoading<Event>, Never>()
    let trackError = PassthroughSubject<TIOUserFacingError, Never>()
    let trackSuccess = PassthroughSubject<TIOSuccessMessage, Never>()

    func presentError(_ error: TIOUserFacingError) {
        trackError.send(error)
    }

    func presentError(message: String, title: String? = L10n.Common.Error.title) {
        presentError(TIOUserFacingError(title: title, message: message))
    }

    func presentSuccess(_ message: String, title: String? = nil) {
        trackSuccess.send(TIOSuccessMessage(title: title, message: message))
    }

    func presentSuccess(_ success: TIOSuccessMessage) {
        trackSuccess.send(success)
    }

    func startLoading(_ event: Event) {
        trackLoading.send(.start(event))
    }

    func stopLoading(_ event: Event) {
        trackLoading.send(.stop(event))
    }
}

extension TIOViewModel where Event == TIOLoadingTarget {

    func startLoading() {
        startLoading(.screen)
    }

    func stopLoading() {
        stopLoading(.screen)
    }
}
