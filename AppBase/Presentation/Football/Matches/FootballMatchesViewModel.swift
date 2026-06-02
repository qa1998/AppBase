//
//  FootballMatchesViewModel.swift
//  AppBase
//

import Combine
import Foundation

final class FootballMatchesViewModel: TIOViewModel<TIOLoadingTarget> {
    
    @Published private(set) var matches: [FootballMatch] = []
    
    private var storeCancel: AnyCancellable?
    
    override init() {
        super.init()
        reload()
        storeCancel = MatchStore.shared.matchesDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.reload()
            }
    }
    
    func reload() {
        matches = MatchStore.shared.matches
    }
}
