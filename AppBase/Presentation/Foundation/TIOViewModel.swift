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

    let trackLoading = PassthroughSubject<TrackLoading<Event>, Never>()

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
