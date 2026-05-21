//
//  MyLineupsViewModel.swift
//  AppBase
//

import Combine
import Foundation

final class MyLineupsViewModel: TIOViewModel<TIOLoadingTarget> {

    @Published private(set) var lineups: [FootballLineup] = []
    @Published var selectedFilter: LineupListFilter = .allTeams

    private var storeCancel: AnyCancellable?

    override init() {
        super.init()
        reload()
        storeCancel = LineupStore.shared.lineupsDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.reload()
            }
    }

    func reload() {
        let all = LineupStore.shared.savedLineups
        switch selectedFilter {
        case .allTeams:
            lineups = all.sorted { $0.updatedAt > $1.updatedAt }
        case .favorites:
            lineups = all.filter(\.isFavorite).sorted { $0.updatedAt > $1.updatedAt }
        case .recent:
            lineups = all.sorted { $0.updatedAt > $1.updatedAt }
        case .drafts:
            lineups = all.filter(\.isDraft).sorted { $0.updatedAt > $1.updatedAt }
        }
    }

    func selectFilter(_ filter: LineupListFilter) {
        selectedFilter = filter
        reload()
    }

    func openLineup(_ lineup: FootballLineup) {
        LineupStore.shared.loadLineup(lineup)
    }

    func createLineup() {
        LineupStore.shared.createNewLineup()
    }

    func toggleFavorite(_ lineup: FootballLineup) {
        LineupStore.shared.updateLineupMetadata(id: lineup.id, isFavorite: !lineup.isFavorite)
        reload()
    }
}
