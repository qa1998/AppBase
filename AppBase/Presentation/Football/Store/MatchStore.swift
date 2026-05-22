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
        guard !UserDefaults.standard.bool(forKey: FormationCatalog.yAxisMatchesMigrationKey) else { return }
        matches = matches.map(flipMatchRosters)
        if let current = currentMatch {
            currentMatch = flipMatchRosters(current)
        }
        UserDefaults.standard.set(true, forKey: FormationCatalog.yAxisMatchesMigrationKey)
        persist()
    }

    private func flipMatchRosters(_ match: FootballMatch) -> FootballMatch {
        var copy = match
        copy.settings.homeRoster = FormationCatalog.flipRoster(copy.settings.homeRoster)
        copy.settings.awayRoster = FormationCatalog.flipRoster(copy.settings.awayRoster)
        return copy
    }

    private func notify() {
        if let currentMatch {
            currentMatchDidChange.send(currentMatch)
        }
        matchesDidChange.send()
    }
}
