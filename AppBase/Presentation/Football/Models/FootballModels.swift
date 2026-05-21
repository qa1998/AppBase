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
        case .gk: return "GK"
        case .def: return "DEF"
        case .mid: return "MID"
        case .fwd: return "FWD"
        }
    }
}

struct FootballPlayer: Identifiable, Equatable {
    let id: String
    let name: String
    let club: String
    let nation: String
    let position: FootballPosition
    let rating: Int
    let initials: String

    static let catalog: [FootballPlayer] = [
        FootballPlayer(id: "1", name: "Erling Haaland", club: "Man City", nation: "NOR", position: .fwd, rating: 91, initials: "EH"),
        FootballPlayer(id: "2", name: "Kevin De Bruyne", club: "Man City", nation: "BEL", position: .mid, rating: 90, initials: "KD"),
        FootballPlayer(id: "3", name: "Virgil van Dijk", club: "Liverpool", nation: "NED", position: .def, rating: 89, initials: "VV"),
        FootballPlayer(id: "4", name: "Alisson Becker", club: "Liverpool", nation: "BRA", position: .gk, rating: 88, initials: "AB"),
        FootballPlayer(id: "5", name: "Bukayo Saka", club: "Arsenal", nation: "ENG", position: .fwd, rating: 87, initials: "BS"),
        FootballPlayer(id: "6", name: "Martin Ødegaard", club: "Arsenal", nation: "NOR", position: .mid, rating: 87, initials: "MØ"),
        FootballPlayer(id: "7", name: "William Saliba", club: "Arsenal", nation: "FRA", position: .def, rating: 86, initials: "WS"),
        FootballPlayer(id: "8", name: "Pedri", club: "Barcelona", nation: "ESP", position: .mid, rating: 86, initials: "PE"),
        FootballPlayer(id: "9", name: "Lamine Yamal", club: "Barcelona", nation: "ESP", position: .fwd, rating: 85, initials: "LY"),
        FootballPlayer(id: "10", name: "Jude Bellingham", club: "Real Madrid", nation: "ENG", position: .mid, rating: 90, initials: "JB"),
        FootballPlayer(id: "11", name: "Vinícius Jr", club: "Real Madrid", nation: "BRA", position: .fwd, rating: 89, initials: "VJ"),
        FootballPlayer(id: "12", name: "Thibaut Courtois", club: "Real Madrid", nation: "BEL", position: .gk, rating: 88, initials: "TC"),
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

enum TacticalStyle: String, CaseIterable {
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
struct TacticalDrawingState: Equatable {
    var strokes: [TacticalStroke] = []
    var undoStack: [[TacticalStroke]] = []
    var redoStack: [[TacticalStroke]] = []

    static let empty = TacticalDrawingState()
}

struct FootballLineup: Identifiable, Equatable {
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

enum TacticalLineStyle: String, CaseIterable, Equatable {
    case solid
    case dashed
}

enum TacticalPathType: String, CaseIterable, Equatable {
    case straight
    case curved
}

enum TacticalLinePointer: String, CaseIterable, Equatable {
    case arrow
    case hollowArrow
    case diamond
    case bar
    case cross
    case none
}

enum TacticalLineColor: String, CaseIterable, Equatable {
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

enum PitchSurfaceStyle: String, CaseIterable, Equatable {
    case full
    case half
    case futsal
}

struct PitchDisplayOptions: Equatable {
    var surfaceStyle: PitchSurfaceStyle = .full
    var showsGrid: Bool = true

    static let `default` = PitchDisplayOptions()
}

struct TacticalLineOptions: Equatable {
    var lineStyle: TacticalLineStyle = .solid
    var pathType: TacticalPathType = .straight
    var pointer: TacticalLinePointer = .cross
    var color: TacticalLineColor = .white

    static let `default` = TacticalLineOptions()
}

struct TacticalStroke: Equatable {
    var points: [CGPoint]
    var options: TacticalLineOptions = .default
}
