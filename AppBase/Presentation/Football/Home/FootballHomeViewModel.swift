//
//  FootballHomeViewModel.swift
//  AppBase
//

import Combine
import Foundation

final class FootballHomeViewModel: TIOViewModel<TIOLoadingTarget> {

    @Published private(set) var recentLineups: [FootballLineup] = []

    private var storeCancel: AnyCancellable?

    override init() {
        super.init()
        recentLineups = LineupStore.shared.savedLineups
        storeCancel = LineupStore.shared.lineupsDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.recentLineups = LineupStore.shared.savedLineups
            }
    }

    var formations: [FootballFormation] {
        Array(FootballFormation.formations(playerCount: 11).prefix(6))
    }

    func createNewLineup() {
        LineupStore.shared.createNewLineup()
    }

    func openLineup(_ lineup: FootballLineup) {
        LineupStore.shared.loadLineup(lineup)
    }
}
