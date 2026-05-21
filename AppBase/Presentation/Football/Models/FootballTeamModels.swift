//
//  FootballTeamModels.swift
//  AppBase
//

import Foundation

/// Đội hình + dự bị cho một cỡ sân (5 / 7 / 11).
struct TeamPitchSetup: Equatable, Codable {
    var formationId: String
    var assignments: [PitchSlotAssignment]
    var benchPlayerIds: [String]

    static func empty(for size: MatchPitchSize) -> TeamPitchSetup {
        let formation = FootballFormation.formations(playerCount: size.playerCount).first
            ?? .default
        let assignments = formation.slots.enumerated().map { index, point in
            PitchSlotAssignment(slotIndex: index, normalizedPosition: point, player: nil)
        }
        return TeamPitchSetup(
            formationId: formation.id,
            assignments: assignments,
            benchPlayerIds: Array(repeating: "", count: MatchTeamRoster.benchSlotCount)
        )
    }

    var filledPitchSlots: Int {
        assignments.filter { $0.player != nil }.count
    }

    var isComplete: Bool {
        !assignments.isEmpty && filledPitchSlots == assignments.count
    }
}

/// Saved squad template — mỗi đội lưu đội hình cho cả 3 cỡ sân.
struct FootballTeam: Identifiable, Equatable, Codable {
    let id: String
    var name: String
    var activePitchSize: MatchPitchSize
    var setups: [String: TeamPitchSetup]
    var updatedAt: Date

    /// Cỡ sân đang chỉnh trong editor (alias).
    var pitchSize: MatchPitchSize { activePitchSize }

    var assignments: [PitchSlotAssignment] { activeSetup.assignments }
    var benchPlayerIds: [String] { activeSetup.benchPlayerIds }
    var formationId: String { activeSetup.formationId }

    var formation: FootballFormation {
        formation(for: activePitchSize)
    }

    func formation(for size: MatchPitchSize) -> FootballFormation {
        let setup = setup(for: size)
        return FootballFormation.formations(playerCount: size.playerCount)
            .first { $0.id == setup.formationId }
            ?? FootballFormation.formations(playerCount: size.playerCount).first
            ?? .default
    }

    func setup(for size: MatchPitchSize) -> TeamPitchSetup {
        setups[size.storageKey] ?? .empty(for: size)
    }

    var activeSetup: TeamPitchSetup {
        setup(for: activePitchSize)
    }

    mutating func writeActiveSetup(_ setup: TeamPitchSetup) {
        setups[activePitchSize.storageKey] = setup
    }

    mutating func setSetup(_ setup: TeamPitchSetup, for size: MatchPitchSize) {
        setups[size.storageKey] = setup
    }

    mutating func setActivePitchSize(_ size: MatchPitchSize) {
        ensureAllSetups()
        activePitchSize = size
    }

    mutating func ensureAllSetups() {
        for size in MatchPitchSize.allCases {
            if setups[size.storageKey] == nil {
                setups[size.storageKey] = .empty(for: size)
            }
        }
    }

    var playerCount: Int {
        max(assignments.count, formation.playerCount)
    }

    var filledPitchSlots: Int {
        activeSetup.filledPitchSlots
    }

    var isRosterComplete: Bool {
        activeSetup.isComplete
    }

    func isRosterComplete(for size: MatchPitchSize) -> Bool {
        setup(for: size).isComplete
    }

    func toMatchRoster(for pitchSize: MatchPitchSize? = nil) -> MatchTeamRoster {
        let size = pitchSize ?? activePitchSize
        let setup = setup(for: size)
        return MatchTeamRoster(
            name: name,
            formationId: setup.formationId,
            assignments: setup.assignments,
            benchPlayerIds: setup.benchPlayerIds
        )
    }

    init(
        id: String = UUID().uuidString,
        name: String = "",
        activePitchSize: MatchPitchSize = .eleven,
        setups: [String: TeamPitchSetup]? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.activePitchSize = activePitchSize
        if let setups {
            self.setups = setups
        } else {
            var built: [String: TeamPitchSetup] = [:]
            for size in MatchPitchSize.allCases {
                built[size.storageKey] = .empty(for: size)
            }
            self.setups = built
        }
        self.updatedAt = updatedAt
        ensureAllSetups()
    }

    static func empty(
        name: String = "",
        activePitchSize: MatchPitchSize = .eleven
    ) -> FootballTeam {
        FootballTeam(name: name, activePitchSize: activePitchSize)
    }

    // MARK: - Codable (migrate legacy single-pitch teams)

    private enum CodingKeys: String, CodingKey {
        case id, name, activePitchSize, setups, updatedAt
        case pitchSize, formationId, assignments, benchPlayerIds
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)

        if let decodedSetups = try container.decodeIfPresent([String: TeamPitchSetup].self, forKey: .setups) {
            setups = decodedSetups
            activePitchSize = try container.decode(MatchPitchSize.self, forKey: .activePitchSize)
        } else {
            let legacySize = try container.decode(MatchPitchSize.self, forKey: .pitchSize)
            let legacySetup = TeamPitchSetup(
                formationId: try container.decode(String.self, forKey: .formationId),
                assignments: try container.decode([PitchSlotAssignment].self, forKey: .assignments),
                benchPlayerIds: try container.decode([String].self, forKey: .benchPlayerIds)
            )
            activePitchSize = legacySize
            setups = [legacySize.storageKey: legacySetup]
        }
        ensureAllSetups()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(activePitchSize, forKey: .activePitchSize)
        try container.encode(setups, forKey: .setups)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

extension MatchPitchSize {
    var storageKey: String { String(rawValue) }
}

struct FootballTeamsSnapshot: Codable, Equatable {
    var teams: [FootballTeam]
    var currentTeamId: String?
}
