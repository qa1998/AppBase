//
//  MatchStore.swift
//  AppBase
//

import Combine
import Foundation

final class MatchStore {

    static let shared = MatchStore()

    let matchesDidChange = PassthroughSubject<Void, Never>()
    let currentMatchDidChange = PassthroughSubject<FootballMatch, Never>()

    private(set) var matches: [FootballMatch] = []
    private(set) var currentMatch: FootballMatch?

    private init() {
        loadFromDisk()
    }

    func createMatch(settings: FootballMatchSettings) -> FootballMatch {
        let match = FootballMatch(settings: settings)
        currentMatch = match
        persist()
        notify()
        return match
    }

    func saveCurrentMatch() {
        guard let match = currentMatch else { return }
        upsert(match)
        persist()
        notify()
    }

    func updateCurrent(_ match: FootballMatch) {
        currentMatch = match
        upsert(match)
        persist()
        currentMatchDidChange.send(match)
        matchesDidChange.send()
    }

    func loadMatch(_ match: FootballMatch) {
        currentMatch = match
        persist()
        currentMatchDidChange.send(match)
    }

    func deleteMatch(id: String) {
        matches.removeAll { $0.id == id }
        if currentMatch?.id == id {
            currentMatch = matches.first
        }
        persist()
        notify()
    }

    func resetAfterDataClear() {
        matches = []
        currentMatch = nil
        persist()
        matchesDidChange.send()
    }

    // MARK: - Persistence

    private func upsert(_ match: FootballMatch) {
        if let index = matches.firstIndex(where: { $0.id == match.id }) {
            matches[index] = match
        } else {
            matches.insert(match, at: 0)
        }
        currentMatch = match
    }

    private func persist() {
        let snapshot = FootballMatchesSnapshot(
            matches: matches,
            currentMatchId: currentMatch?.id
        )
        DataStore.shared.set(snapshot, forKey: .footballMatches)
    }

    private func loadFromDisk() {
        guard let snapshot = DataStore.shared.value(
            forKey: .footballMatches,
            type: FootballMatchesSnapshot.self
        ) else {
            return
        }
        matches = snapshot.matches
        if let id = snapshot.currentMatchId {
            currentMatch = matches.first { $0.id == id }
        }
        migratePitchYAxisIfNeeded()
    }

    private func migratePitchYAxisIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: PitchFormationGridLayout.gridLayoutMatchesMigrationKey) else { return }
        matches = matches.map { Self.realignMatchToGrid($0) }
        if let current = currentMatch {
            currentMatch = Self.realignMatchToGrid(current)
        }
        UserDefaults.standard.set(true, forKey: PitchFormationGridLayout.gridLayoutMatchesMigrationKey)
        persist()
    }

    private static func realignMatchToGrid(_ match: FootballMatch) -> FootballMatch {
        var copy = match
        let size = copy.settings.pitchSize
        copy.settings.homeRoster = realignRoster(copy.settings.homeRoster, pitchSize: size)
        copy.settings.awayRoster = realignRoster(copy.settings.awayRoster, pitchSize: size)
        return copy
    }

    private static func realignRoster(_ roster: MatchTeamRoster, pitchSize: MatchPitchSize) -> MatchTeamRoster {
        var copy = roster
        let formation = FootballFormation.catalog.first { $0.id == roster.formationId }
            ?? FootballFormation.formations(playerCount: pitchSize.playerCount).first
            ?? .default
        copy.assignments = PitchFormationGridLayout.realignAssignments(copy.assignments, formation: formation)
        return copy
    }

    private func notify() {
        if let currentMatch {
            currentMatchDidChange.send(currentMatch)
        }
        matchesDidChange.send()
    }
}
