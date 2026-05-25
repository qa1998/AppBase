//
//  FootballDataClearService.swift
//  AppBase
//

import Foundation

enum FootballDataClearService {

    static func clearAllFootballData() {
        [
            StorageKey.footballMatches,
            .footballLineups,
            .footballTeams,
            .footballPlayers,
        ].forEach { DataStore.shared.remove(forKey: $0) }

        UserDefaults.standard.removeObject(forKey: "football.formation.favorites")
        FormationFavoritesStore.shared.resetAfterDataClear()

        LineupStore.shared.resetAfterDataClear()
        TeamStore.shared.resetAfterDataClear()
        PlayerStore.shared.resetAfterDataClear()
        MatchStore.shared.resetAfterDataClear()
    }
}
