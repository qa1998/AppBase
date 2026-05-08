//
//  AppState.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import Combine

enum AppState: Equatable {
    case welcome
    case login
    case main
    case logout
    case maintain
}

class AppStateEvent {
    static let `default` = AppStateEvent()
    
    let state = PassthroughSubject<AppState, Never>()
    
    static func set(state: AppState) {
        let appState = AppStateEvent.default
        appState.state.send(state)
    }
}

