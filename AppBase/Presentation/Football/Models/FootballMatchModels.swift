//
//  FootballMatchModels.swift
//  AppBase
//

import Foundation

enum MatchPitchSize: Int, CaseIterable, Codable, Equatable {
    case five = 5
    case seven = 7
    case eleven = 11

    var playerCount: Int { rawValue }
}

enum MatchPhase: String, Codable, Equatable {
    case scheduled
    case firstHalfRunning
    case firstHalfStoppage
    case halftime
    case secondHalfRunning
    case secondHalfStoppage
    case extraFirstRunning
    case extraHalftime
    case extraSecondRunning
    case extraSecondStoppage
    case penaltyShootout
    case finished
}

enum MatchHalf: Int, CaseIterable, Codable, Equatable {
    case first = 1
    case second = 2
    case extraFirst = 3
    case extraSecond = 4
    case penalties = 5
}

enum MatchTeamSide: String, Codable, Equatable {
    case home
    case away
    case neutral
}

enum MatchEventType: String, CaseIterable, Codable, Equatable {
    case goal
    case yellowCard
    case redCard
    case substitution
    case varReview
    case penalty

    var iconName: String {
        switch self {
        case .goal: return "soccerball"
        case .yellowCard: return "rectangle.fill"
        case .redCard: return "rectangle.fill"
        case .substitution: return "arrow.left.arrow.right"
        case .varReview: return "tv"
        case .penalty: return "flag.fill"
        }
    }
}

struct MatchEvent: Identifiable, Equatable, Codable {
    let id: String
    let type: MatchEventType
    let team: MatchTeamSide
    let playerId: String
    let playerName: String
    let half: MatchHalf
    let minute: Int
    let stoppageMinute: Int?
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        type: MatchEventType,
        team: MatchTeamSide,
        player: FootballPlayer,
        half: MatchHalf,
        minute: Int,
        stoppageMinute: Int? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.team = team
        self.playerId = player.id
        self.playerName = player.name
        self.half = half
        self.minute = minute
        self.stoppageMinute = stoppageMinute
        self.createdAt = createdAt
    }
}

/// Pitch slot or bench slot when assigning players during match setup.
enum MatchRosterSlot: Equatable {
    case pitch(Int)
    case bench(Int)
}

struct MatchTeamRoster: Equatable {
    static let benchSlotCount = 5

    var name: String
    var formationId: String
    var assignments: [PitchSlotAssignment]
    /// Up to `benchSlotCount` player ids; empty string = empty bench slot.
    var benchPlayerIds: [String]

    static func empty(name: String, pitchSize: MatchPitchSize) -> MatchTeamRoster {
        let formation = FootballFormation.formations(playerCount: pitchSize.playerCount).first
            ?? FootballFormation.default
        let assignments = formation.slots.enumerated().map { index, point in
            PitchSlotAssignment(slotIndex: index, normalizedPosition: point, player: nil)
        }
        return MatchTeamRoster(
            name: name,
            formationId: formation.id,
            assignments: assignments,
            benchPlayerIds: Array(repeating: "", count: benchSlotCount)
        )
    }

    var filledPitchSlots: Int {
        assignments.filter { $0.player != nil }.count
    }

    var filledBenchSlots: Int {
        benchPlayerIds.filter { !$0.isEmpty }.count
    }

    var isPitchComplete: Bool {
        !assignments.isEmpty && filledPitchSlots == assignments.count
    }

    var isComplete: Bool {
        isPitchComplete
    }

    func player(forSlot index: Int) -> FootballPlayer? {
        assignments[safe: index]?.player
    }

    func benchPlayer(at index: Int) -> FootballPlayer? {
        guard let id = benchPlayerIds[safe: index], !id.isEmpty else { return nil }
        return FootballPlayer.resolved(id: id)
    }

    mutating func setBenchPlayer(_ player: FootballPlayer?, at index: Int) {
        guard index >= 0, index < Self.benchSlotCount else { return }
        while benchPlayerIds.count < Self.benchSlotCount {
            benchPlayerIds.append("")
        }
        benchPlayerIds[index] = player?.id ?? ""
    }

    var playersOnPitch: [FootballPlayer] {
        assignments.compactMap(\.player)
    }

    var benchPlayers: [FootballPlayer] {
        benchPlayerIds.compactMap { id in
            guard !id.isEmpty else { return nil }
            return FootballPlayer.resolved(id: id)
        }
    }

    var allSquadPlayers: [FootballPlayer] {
        playersOnPitch + benchPlayers
    }
}

struct FootballMatchSettings: Equatable, Codable {
    var homeTeam: String
    var awayTeam: String
    var pitchSize: MatchPitchSize
    var kickoffDate: Date
    var firstHalfMinutes: Int
    var secondHalfMinutes: Int
    var extraTimeHalfMinutes: Int
    var hasExtraTime: Bool
    var hasPenaltyShootout: Bool
    var homeRoster: MatchTeamRoster
    var awayRoster: MatchTeamRoster

    static let defaultFirstHalf = 45
    static let defaultSecondHalf = 45
    static let defaultExtraHalf = 15

    /// Phút bắt đầu hiệp trên đồng hồ trận (tích lũy từ kickoff).
    func kickoffMinuteOffset(for half: MatchHalf) -> Int {
        switch half {
        case .first:
            return 0
        case .second:
            return firstHalfMinutes
        case .extraFirst:
            return firstHalfMinutes + secondHalfMinutes
        case .extraSecond:
            return firstHalfMinutes + secondHalfMinutes + extraTimeHalfMinutes
        case .penalties:
            let extra = hasExtraTime ? extraTimeHalfMinutes * 2 : 0
            return firstHalfMinutes + secondHalfMinutes + extra
        }
    }

    func halfLengthMinutes(for half: MatchHalf) -> Int {
        switch half {
        case .first: return firstHalfMinutes
        case .second: return secondHalfMinutes
        case .extraFirst, .extraSecond: return extraTimeHalfMinutes
        case .penalties: return 0
        }
    }
}

extension MatchEvent {

    /// Phút hiển thị timeline — luôn theo tổng thời gian trận (phút 1 = kickoff).
    func timelineMinute(settings: FootballMatchSettings) -> (minute: Int, stoppage: Int?) {
        let offset = settings.kickoffMinuteOffset(for: half)
        let cumulativeMinute: Int
        if half == .first {
            cumulativeMinute = minute
        } else if minute > offset {
            cumulativeMinute = minute
        } else {
            cumulativeMinute = offset + minute
        }

        if let stoppage = stoppageMinute {
            let halfEnd = offset + settings.halfLengthMinutes(for: half)
            return (halfEnd, stoppage)
        }
        return (cumulativeMinute, nil)
    }
}

struct FootballMatch: Identifiable, Equatable, Codable {
    let id: String
    var settings: FootballMatchSettings
    var phase: MatchPhase
    var events: [MatchEvent]
    /// Elapsed seconds shown for the active segment (derived when running).
    var elapsedSeconds: Int
    /// Anchor when the current running segment started (persisted for resume).
    var clockBaseSeconds: Int
    var segmentStartedAt: Date?
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        settings: FootballMatchSettings,
        phase: MatchPhase = .scheduled,
        events: [MatchEvent] = [],
        elapsedSeconds: Int = 0,
        clockBaseSeconds: Int = 0,
        segmentStartedAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.settings = settings
        self.phase = phase
        self.events = events
        self.elapsedSeconds = elapsedSeconds
        self.clockBaseSeconds = clockBaseSeconds
        self.segmentStartedAt = segmentStartedAt
        self.createdAt = createdAt
    }

    func roster(for side: MatchTeamSide) -> MatchTeamRoster {
        switch side {
        case .home: return settings.homeRoster
        case .away: return settings.awayRoster
        case .neutral: return settings.homeRoster
        }
    }

    var scoreLine: String {
        let homeGoals = events.filter { $0.type == .goal && $0.team == .home }.count
        let awayGoals = events.filter { $0.type == .goal && $0.team == .away }.count
        return "\(homeGoals) - \(awayGoals)"
    }
}

// MARK: - Codable (bench migration)

extension MatchTeamRoster: Codable {

    enum CodingKeys: String, CodingKey {
        case name, formationId, assignments, benchPlayerIds
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        formationId = try container.decode(String.self, forKey: .formationId)
        assignments = try container.decode([PitchSlotAssignment].self, forKey: .assignments)
        benchPlayerIds = try container.decodeIfPresent([String].self, forKey: .benchPlayerIds)
            ?? Array(repeating: "", count: Self.benchSlotCount)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(formationId, forKey: .formationId)
        try container.encode(assignments, forKey: .assignments)
        try container.encode(benchPlayerIds, forKey: .benchPlayerIds)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
