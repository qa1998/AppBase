//
//  FootballModels.swift
//  AppBase
//

import CoreGraphics
import Foundation
import UIKit

enum FootballPosition: String, CaseIterable, Codable {
    case gk, def, mid, fwd

    var label: String {
        switch self {
        case .gk: return L10n.Football.Players.Position.gk
        case .def: return L10n.Football.Players.Position.def
        case .mid: return L10n.Football.Players.Position.mid
        case .fwd: return L10n.Football.Players.Position.fwd
        }
    }
}

struct FootballPlayer: Identifiable, Equatable, Codable {
    let id: String
    let name: String
    let club: String
    let nation: String
    let position: FootballPosition
    let rating: Int
    let initials: String
    /// File name under player avatars directory.
    let avatarFileName: String?
    var avatarUrlString: String? = nil
    /// Squad number (1–99); nil for catalog / unset.
    let jerseyNumber: Int?

    var jerseyDisplay: String? {
        guard let jerseyNumber, jerseyNumber > 0 else { return nil }
        return "\(jerseyNumber)"
    }

    func updating(
        name: String? = nil,
        position: FootballPosition? = nil,
        initials: String? = nil,
        avatarFileName: String? = nil,
        jerseyNumber: Int? = nil
    ) -> FootballPlayer {
        FootballPlayer(
            id: id,
            name: name ?? self.name,
            club: club,
            nation: nation,
            position: position ?? self.position,
            rating: rating,
            initials: initials ?? self.initials,
            avatarFileName: avatarFileName ?? self.avatarFileName,
            avatarUrlString: nil,
            jerseyNumber: jerseyNumber ?? self.jerseyNumber
        )
    }

    var avatarImage: UIImage? {
        guard let avatarFileName else { return nil }
        return FootballPlayerAvatarStorage.load(fileName: avatarFileName)
    }

    static func resolved(id: String) -> FootballPlayer? {
        PlayerStore.shared.player(id: id) ?? catalog.first { $0.id == id }
    }

    static func makeInitials(from name: String) -> String {
        let parts = name.split(separator: " ").filter { !$0.isEmpty }
        if parts.count >= 2 {
            let a = parts[0].prefix(1)
            let b = parts[1].prefix(1)
            return "\(a)\(b)".uppercased()
        }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(trimmed.prefix(2)).uppercased()
    }

    static func custom(
        name: String,
        position: FootballPosition,
        jerseyNumber: Int? = nil,
        avatarFileName: String? = nil
    ) -> FootballPlayer {
        FootballPlayer(
            id: UUID().uuidString,
            name: name,
            club: "",
            nation: "",
            position: position,
            rating: 0,
            initials: makeInitials(from: name),
            avatarFileName: avatarFileName,
            avatarUrlString: nil,
            jerseyNumber: jerseyNumber
        )
    }

    /// Placeholder for neutral match events (e.g. VAR).
    static let neutralEvent = FootballPlayer(
        id: "neutral",
        name: "",
        club: "",
        nation: "",
        position: .mid,
        rating: 0,
        initials: "—",
        avatarFileName: nil,
        avatarUrlString: nil,
        jerseyNumber: nil
    )

    static let catalog: [FootballPlayer] = [
        FootballPlayer(id: "1", name: "Erling Haaland", club: "Man City", nation: "NOR", position: .fwd, rating: 91, initials: "EH", avatarFileName: nil, jerseyNumber: nil),
        FootballPlayer(id: "2", name: "Kevin De Bruyne", club: "Man City", nation: "BEL", position: .mid, rating: 90, initials: "KD", avatarFileName: nil, jerseyNumber: nil),
        FootballPlayer(id: "3", name: "Virgil van Dijk", club: "Liverpool", nation: "NED", position: .def, rating: 89, initials: "VV", avatarFileName: nil, jerseyNumber: nil),
        FootballPlayer(id: "4", name: "Alisson Becker", club: "Liverpool", nation: "BRA", position: .gk, rating: 88, initials: "AB", avatarFileName: nil, jerseyNumber: nil),
        FootballPlayer(id: "5", name: "Bukayo Saka", club: "Arsenal", nation: "ENG", position: .fwd, rating: 87, initials: "BS", avatarFileName: nil, jerseyNumber: nil),
        FootballPlayer(id: "6", name: "Martin Ødegaard", club: "Arsenal", nation: "NOR", position: .mid, rating: 87, initials: "MØ", avatarFileName: nil, jerseyNumber: nil),
        FootballPlayer(id: "7", name: "William Saliba", club: "Arsenal", nation: "FRA", position: .def, rating: 86, initials: "WS", avatarFileName: nil, jerseyNumber: nil),
        FootballPlayer(id: "8", name: "Pedri", club: "Barcelona", nation: "ESP", position: .mid, rating: 86, initials: "PE", avatarFileName: nil, jerseyNumber: nil),
        FootballPlayer(id: "9", name: "Lamine Yamal", club: "Barcelona", nation: "ESP", position: .fwd, rating: 85, initials: "LY", avatarFileName: nil, jerseyNumber: nil),
        FootballPlayer(id: "10", name: "Jude Bellingham", club: "Real Madrid", nation: "ENG", position: .mid, rating: 90, initials: "JB", avatarFileName: nil, jerseyNumber: nil),
        FootballPlayer(id: "11", name: "Vinícius Jr", club: "Real Madrid", nation: "BRA", position: .fwd, rating: 89, initials: "VJ", avatarFileName: nil, jerseyNumber: nil),
        FootballPlayer(id: "12", name: "Thibaut Courtois", club: "Real Madrid", nation: "BEL", position: .gk, rating: 88, initials: "TC", avatarFileName: nil, jerseyNumber: nil),
    ]
}

struct FootballFormation: Identifiable, Equatable {
    let id: String
    let name: String
    /// Normalized positions on pitch (x: 0=left, 1=right; y: 0=attack, 1=defense).
    let slots: [CGPoint]
}

struct PitchSlotAssignment: Equatable {
    var slotIndex: Int
    var normalizedPosition: CGPoint
    var player: FootballPlayer?
}

enum TacticalStyle: String, CaseIterable, Codable {
    case attacking
    case balanced
    case defensive

    var label: String {
        switch self {
        case .attacking: return L10n.Football.Lineups.Style.attacking
        case .balanced: return L10n.Football.Lineups.Style.balanced
        case .defensive: return L10n.Football.Lineups.Style.defensive
        }
    }
}

enum LineupListFilter: Int, CaseIterable {
    case allTeams
    case favorites
    case recent
    case drafts

    var title: String {
        switch self {
        case .allTeams: return L10n.Football.Lineups.Filter.allTeams
        case .favorites: return L10n.Football.Lineups.Filter.favorites
        case .recent: return L10n.Football.Lineups.Filter.recent
        case .drafts: return L10n.Football.Lineups.Filter.drafts
        }
    }
}

/// Tactical lines on the pitch plus undo / redo history for the editor.
struct TacticalDrawingState: Equatable, Codable {
    var strokes: [TacticalStroke] = []
    var undoStack: [[TacticalStroke]] = []
    var redoStack: [[TacticalStroke]] = []

    static let empty = TacticalDrawingState()
}

struct FootballLineup: Identifiable, Equatable, Codable {
    let id: String
    var title: String
    var formationId: String
    var tacticalStyle: TacticalStyle
    var isFavorite: Bool
    var isDraft: Bool
    var assignments: [PitchSlotAssignment]
    var benchPlayerIds: [String]
    var updatedAt: Date
    var tacticalDrawing: TacticalDrawingState = .empty
    var tacticalLineOptions: TacticalLineOptions = .default
    var pitchDisplayOptions: PitchDisplayOptions = .default

    var formation: FootballFormation {
        FootballFormation.catalog.first { $0.id == formationId } ?? .default
    }

    /// User-facing title; empty stored name shows localized “untitled”.
    var displayTitle: String {
        Self.displayTitle(for: title)
    }

    static func displayTitle(for rawTitle: String) -> String {
        let trimmed = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? L10n.Football.Editor.untitled : trimmed
    }

    /// Số cầu thủ trên sân (GK + outfield).
    var playerCount: Int {
        max(assignments.count, formation.playerCount)
    }

    var relativeEditedText: String {
        let interval = Date().timeIntervalSince(updatedAt)
        if interval < 3600 {
            let minutes = max(1, Int(interval / 60))
            return L10n.Football.Lineups.editedMinutesAgo(minutes)
        }
        if interval < 86_400 {
            let hours = max(1, Int(interval / 3600))
            return L10n.Football.Lineups.editedHoursAgo(hours)
        }
        let days = max(1, Int(interval / 86_400))
        return L10n.Football.Lineups.editedDaysAgo(days)
    }
}

enum TacticalLineStyle: String, CaseIterable, Equatable, Codable {
    case solid
    case dashed
}

enum TacticalPathType: String, CaseIterable, Equatable, Codable {
    case straight
    case curved
}

enum TacticalLinePointer: String, CaseIterable, Equatable, Codable {
    case arrow
    case hollowArrow
    case diamond
    case bar
    case cross
    case none
}

enum TacticalLineColor: String, CaseIterable, Equatable, Codable {
    case white
    case blue
    case red
    case yellow
    case orange
    case purple

    var uiColor: UIColor {
        switch self {
        case .white: return .white
        case .blue: return UIColor(hex: 0x3B82F6)
        case .red: return FootballPalette.accentRed
        case .yellow: return UIColor(hex: 0xFACC15)
        case .orange: return UIColor(hex: 0xFB923C)
        case .purple: return UIColor(hex: 0xA855F7)
        }
    }
}

enum PitchSurfaceStyle: String, CaseIterable, Equatable, Codable {
    case full
    case half
    case futsal
}

struct PitchDisplayOptions: Equatable, Codable {
    var surfaceStyle: PitchSurfaceStyle = .full
    var showsGrid: Bool = true

    static let `default` = PitchDisplayOptions()
}

struct TacticalLineOptions: Equatable, Codable {
    var lineStyle: TacticalLineStyle = .solid
    var pathType: TacticalPathType = .straight
    var pointer: TacticalLinePointer = .cross
    var color: TacticalLineColor = .white

    static let `default` = TacticalLineOptions()
}

struct TacticalStroke: Equatable, Codable {
    var points: [CGPoint]
    var options: TacticalLineOptions = .default
}

// MARK: - Codable (player stored as id)

extension PitchSlotAssignment: Codable {

    private enum CodingKeys: String, CodingKey {
        case slotIndex
        case normalizedPosition
        case playerId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        slotIndex = try container.decode(Int.self, forKey: .slotIndex)
        normalizedPosition = try container.decode(CGPoint.self, forKey: .normalizedPosition)
        if let playerId = try container.decodeIfPresent(String.self, forKey: .playerId) {
            player = FootballPlayer.resolved(id: playerId)
        } else {
            player = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(slotIndex, forKey: .slotIndex)
        try container.encode(normalizedPosition, forKey: .normalizedPosition)
        try container.encodeIfPresent(player?.id, forKey: .playerId)
    }
}
