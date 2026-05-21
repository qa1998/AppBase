//
//  FootballTeamModels.swift
//  AppBase
//

import Foundation

/// Saved squad template — dùng lại khi tạo trận (không có vẽ chiến thuật).
struct FootballTeam: Identifiable, Equatable, Codable {
    let id: String
    var name: String
    var pitchSize: MatchPitchSize
    var formationId: String
    var assignments: [PitchSlotAssignment]
    var benchPlayerIds: [String]
    var updatedAt: Date

    var formation: FootballFormation {
        FootballFormation.formations(playerCount: pitchSize.playerCount)
            .first { $0.id == formationId }
            ?? FootballFormation.formations(playerCount: pitchSize.playerCount).first
            ?? .default
    }

    var playerCount: Int {
        max(assignments.count, formation.playerCount)
    }

    var filledPitchSlots: Int {
        assignments.filter { $0.player != nil }.count
    }

    var isRosterComplete: Bool {
        !assignments.isEmpty && filledPitchSlots == assignments.count
    }

    func toMatchRoster() -> MatchTeamRoster {
        MatchTeamRoster(
            name: name,
            formationId: formationId,
            assignments: assignments,
            benchPlayerIds: benchPlayerIds
        )
    }

    static func empty(
        name: String = "",
        pitchSize: MatchPitchSize = .eleven
    ) -> FootballTeam {
        let formation = FootballFormation.formations(playerCount: pitchSize.playerCount).first
            ?? .default
        let assignments = formation.slots.enumerated().map { index, point in
            PitchSlotAssignment(slotIndex: index, normalizedPosition: point, player: nil)
        }
        return FootballTeam(
            id: UUID().uuidString,
            name: name,
            pitchSize: pitchSize,
            formationId: formation.id,
            assignments: assignments,
            benchPlayerIds: Array(repeating: "", count: MatchTeamRoster.benchSlotCount),
            updatedAt: Date()
        )
    }
}

struct FootballTeamsSnapshot: Codable, Equatable {
    var teams: [FootballTeam]
    var currentTeamId: String?
}
