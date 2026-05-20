//
//  TrackLoading.swift
//  AppBase
//

import Foundation

enum TrackLoading<Event> {
    case start(Event)
    case stop(Event)

    var event: Event {
        switch self {
        case .start(let event), .stop(let event):
            return event
        }
    }

    var isLoading: Bool {
        switch self {
        case .start:
            return true
        case .stop:
            return false
        }
    }
}

/// Loading cả màn — truyền `.screen` khi gọi `startLoading(.screen)`.
enum TIOLoadingTarget: Hashable {
    case screen
}
