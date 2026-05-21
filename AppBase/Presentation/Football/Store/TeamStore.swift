//
//  TeamStore.swift
//  AppBase
//

import Combine
import Foundation

final class TeamStore {

    static let shared = TeamStore()

    let teamsDidChange = PassthroughSubject<Void, Never>()
    let currentTeamDidChange = PassthroughSubject<FootballTeam, Never>()

    private(set) var teams: [FootballTeam] = []
    private(set) var currentTeam: FootballTeam

    private init() {
        if let snapshot = DataStore.shared.value(
            forKey: .footballTeams,
            type: FootballTeamsSnapshot.self
        ) {
            teams = snapshot.teams
            if let id = snapshot.currentTeamId,
               let team = teams.first(where: { $0.id == id }) {
                currentTeam = team
            } else {
                currentTeam = FootballTeam.empty()
            }
        } else {
            currentTeam = FootballTeam.empty()
            persist()
        }
    }

    func team(id: String) -> FootballTeam? {
        teams.first { $0.id == id }
    }

    func createNewTeam() {
        currentTeam = FootballTeam.empty(name: L10n.Football.Teams.defaultName)
        notify()
    }

    func loadTeam(_ team: FootballTeam) {
        currentTeam = team
        currentTeamDidChange.send(team)
    }

    func updateCurrent(_ team: FootballTeam) {
        currentTeam = team
        if let index = teams.firstIndex(where: { $0.id == team.id }) {
            teams[index] = team
        }
        persist()
        currentTeamDidChange.send(team)
        teamsDidChange.send()
    }

    func saveCurrentTeam() {
        var copy = currentTeam
        copy.updatedAt = Date()
        currentTeam = copy
        if let index = teams.firstIndex(where: { $0.id == copy.id }) {
            teams[index] = copy
        } else {
            teams.insert(copy, at: 0)
        }
        persist()
        notify()
    }

    func deleteTeam(id: String) {
        teams.removeAll { $0.id == id }
        if currentTeam.id == id {
            currentTeam = FootballTeam.empty()
        }
        persist()
        teamsDidChange.send()
    }

    func setPitchSize(_ size: MatchPitchSize) {
        var team = currentTeam
        guard team.pitchSize != size else { return }
        team.pitchSize = size
        let formation = FootballFormation.formations(playerCount: size.playerCount).first ?? .default
        team.formationId = formation.id
        team.assignments = formation.slots.enumerated().map { index, point in
            PitchSlotAssignment(slotIndex: index, normalizedPosition: point, player: nil)
        }
        team.benchPlayerIds = Array(repeating: "", count: MatchTeamRoster.benchSlotCount)
        currentTeam = team
        notify()
    }

    func applyFormation(_ formation: FootballFormation) {
        var team = currentTeam
        team.formationId = formation.id
        team.assignments = formation.slots.enumerated().map { index, point in
            let existing = team.assignments[safe: index]?.player
            return PitchSlotAssignment(slotIndex: index, normalizedPosition: point, player: existing)
        }
        currentTeam = team
        notify()
    }

    func assignPlayer(_ player: FootballPlayer, pitchSlot index: Int) {
        guard currentTeam.assignments.indices.contains(index) else { return }
        currentTeam.assignments[index].player = player
        notify()
    }

    func setBenchPlayer(_ player: FootballPlayer?, at index: Int) {
        guard index >= 0, index < MatchTeamRoster.benchSlotCount else { return }
        while currentTeam.benchPlayerIds.count < MatchTeamRoster.benchSlotCount {
            currentTeam.benchPlayerIds.append("")
        }
        currentTeam.benchPlayerIds[index] = player?.id ?? ""
        notify()
    }

    func benchPlayer(at index: Int) -> FootballPlayer? {
        guard let id = currentTeam.benchPlayerIds[safe: index], !id.isEmpty else { return nil }
        return FootballPlayer.resolved(id: id)
    }

    private func persist() {
        let snapshot = FootballTeamsSnapshot(
            teams: teams,
            currentTeamId: currentTeam.id
        )
        DataStore.shared.set(snapshot, forKey: .footballTeams)
    }

    private func notify() {
        currentTeamDidChange.send(currentTeam)
        teamsDidChange.send()
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
