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
            teams = snapshot.teams.map { team in
                var copy = team
                copy.ensureAllSetups()
                return copy
            }
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
        var copy = team
        copy.ensureAllSetups()
        currentTeam = copy
        currentTeamDidChange.send(copy)
    }

    func updateCurrent(_ team: FootballTeam) {
        var copy = team
        copy.ensureAllSetups()
        currentTeam = copy
        if let index = teams.firstIndex(where: { $0.id == copy.id }) {
            teams[index] = copy
        }
        persist()
        currentTeamDidChange.send(copy)
        teamsDidChange.send()
    }

    func saveCurrentTeam() {
        var copy = currentTeam
        copy.ensureAllSetups()
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

    /// Chuyển tab cỡ sân — giữ nguyên đội hình từng sân đã lưu trong `setups`.
    func setPitchSize(_ size: MatchPitchSize) {
        var team = currentTeam
        guard team.activePitchSize != size else { return }
        team.ensureAllSetups()
        team.activePitchSize = size
        currentTeam = team
        notify()
    }

    func applyFormation(_ formation: FootballFormation) {
        var team = currentTeam
        var setup = team.activeSetup
        setup.formationId = formation.id
        setup.assignments = formation.slots.enumerated().map { index, point in
            let existing = setup.assignments[safe: index]?.player
            return PitchSlotAssignment(
                slotIndex: index,
                normalizedPosition: point,
                player: existing
            )
        }
        team.writeActiveSetup(setup)
        currentTeam = team
        notify()
    }

    func assignPlayer(_ player: FootballPlayer, pitchSlot index: Int) {
        var team = currentTeam
        var setup = team.activeSetup
        guard setup.assignments.indices.contains(index) else { return }
        setup.assignments[index].player = player
        team.writeActiveSetup(setup)
        currentTeam = team
        notify()
    }

    func setBenchPlayer(_ player: FootballPlayer?, at index: Int) {
        guard index >= 0, index < MatchTeamRoster.benchSlotCount else { return }
        var team = currentTeam
        var setup = team.activeSetup
        while setup.benchPlayerIds.count < MatchTeamRoster.benchSlotCount {
            setup.benchPlayerIds.append("")
        }
        setup.benchPlayerIds[index] = player?.id ?? ""
        team.writeActiveSetup(setup)
        currentTeam = team
        notify()
    }

    func benchPlayer(at index: Int) -> FootballPlayer? {
        guard let id = currentTeam.activeSetup.benchPlayerIds[safe: index], !id.isEmpty else { return nil }
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
