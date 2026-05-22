//
//  FormationCatalog.swift
//  AppBase
//

import CoreGraphics
import Foundation

extension FootballFormation {

    var playerCount: Int { slots.count }

    /// All tactical presets grouped by outfield + GK count.
    static var catalog: [FootballFormation] {
        FormationCatalog.all
    }

    static func formations(playerCount: Int) -> [FootballFormation] {
        catalog.filter { $0.playerCount == playerCount }
    }

    static let `default` = catalog.first { $0.name == "4-3-3" } ?? catalog[0]
}

enum FormationCatalog {

    static let playerCounts = [11, 10, 9, 8, 7, 6, 5]

    static let all: [FootballFormation] = {
        var list: [FootballFormation] = []
        for count in playerCounts {
            list.append(contentsOf: presets(for: count))
        }
        return list
    }()

    private static func presets(for count: Int) -> [FootballFormation] {
        let names: [String]
        switch count {
        case 11:
            names = [
                "3-2-3-2", "3-3-3-1", "3-4-1-2", "3-4-2-1", "3-4-3",
                "3-5-1-1", "3-5-2", "4-1-2-3", "4-1-3-2", "4-1-4-1",
                "4-2-1-3", "4-2-2-2", "4-2-3-1", "4-3-3", "4-4-2",
                "4-4-1-1", "4-5-1", "5-3-2", "5-4-1",
            ]
        case 10:
            names = ["3-3-2-2", "3-4-2-1", "4-1-2-3", "4-2-2-2", "4-3-3", "4-4-1-1", "3-5-2"]
        case 9:
            names = ["3-2-2-2", "3-3-3", "3-4-2", "4-1-2-2", "4-2-3", "4-3-2"]
        case 8:
            names = ["3-2-3", "3-3-2", "4-1-2-1", "4-2-2", "4-3-1"]
        case 7:
            names = ["3-2-2", "3-3-1", "4-1-2", "4-2-1", "3-4"]
        case 6:
            names = ["3-1-2", "3-2-1", "4-1-1", "2-2-2", "3-3"]
        case 5:
            names = ["2-1-2", "3-1-1", "2-2-1", "1-2-2", "3-2"]
        default:
            names = []
        }
        return names.map { name in
            FootballFormation(
                id: "\(count)-\(name)",
                name: name,
                slots: makeSlots(lineCounts: parseLines(name), totalPlayers: count)
            )
        }
    }

    private static func parseLines(_ name: String) -> [Int] {
        name.split(separator: "-").compactMap { Int($0) }
    }

    /// GK + outfield lines; trims or pads to `totalPlayers`.
    static func makeSlots(lineCounts: [Int], totalPlayers: Int) -> [CGPoint] {
        var lines = lineCounts
        var sum = lines.reduce(0, +)
        while sum > totalPlayers - 1, !lines.isEmpty {
            if let idx = lines.indices.max(by: { lines[$0] < lines[$1] }) {
                lines[idx] -= 1
                sum -= 1
            } else { break }
        }
        while sum < totalPlayers - 1 {
            lines.append(1)
            sum += 1
        }

        // y: 0 = attack (top), 1 = defense / GK (bottom) — see FootballFormation.slots
        var points: [CGPoint] = [CGPoint(x: 0.5, y: 0.92)]
        let rowCount = lines.count
        for (row, count) in lines.enumerated() {
            let depth = CGFloat(row + 1) / CGFloat(rowCount + 1)
            let y = 0.92 - depth * 0.68
            for col in 0..<count {
                let x = CGFloat(col + 1) / CGFloat(count + 1)
                points.append(CGPoint(x: x, y: y))
            }
        }
        while points.count < totalPlayers {
            points.append(CGPoint(x: 0.5, y: 0.5))
        }
        return Array(points.prefix(totalPlayers))
    }

    // MARK: - Y-axis migration (old builds had GK at top)

    static let yAxisLineupsMigrationKey = "football.pitch.yAxisFlipped.lineups.v1"
    static let yAxisTeamsMigrationKey = "football.pitch.yAxisFlipped.teams.v1"
    static let yAxisMatchesMigrationKey = "football.pitch.yAxisFlipped.matches.v1"

    static func flipPitchY(_ point: CGPoint) -> CGPoint {
        CGPoint(x: point.x, y: 1 - point.y)
    }

    static func flipLineup(_ lineup: FootballLineup) -> FootballLineup {
        var copy = lineup
        copy.assignments = copy.assignments.map { slot in
            var s = slot
            s.normalizedPosition = flipPitchY(s.normalizedPosition)
            return s
        }
        copy.tacticalDrawing = flipDrawingState(copy.tacticalDrawing)
        return copy
    }

    static func flipDrawingState(_ state: TacticalDrawingState) -> TacticalDrawingState {
        var copy = state
        copy.strokes = copy.strokes.map(flipStroke)
        copy.undoStack = copy.undoStack.map { $0.map(flipStroke) }
        copy.redoStack = copy.redoStack.map { $0.map(flipStroke) }
        return copy
    }

    static func flipStroke(_ stroke: TacticalStroke) -> TacticalStroke {
        var copy = stroke
        copy.points = copy.points.map(flipPitchY)
        return copy
    }

    static func flipRoster(_ roster: MatchTeamRoster) -> MatchTeamRoster {
        var copy = roster
        copy.assignments = copy.assignments.map { slot in
            var s = slot
            s.normalizedPosition = flipPitchY(s.normalizedPosition)
            return s
        }
        return copy
    }

    static func flipTeamSetups(_ team: FootballTeam) -> FootballTeam {
        var copy = team
        for key in copy.setups.keys {
            guard var setup = copy.setups[key] else { continue }
            setup.assignments = setup.assignments.map { slot in
                var s = slot
                s.normalizedPosition = flipPitchY(s.normalizedPosition)
                return s
            }
            copy.setups[key] = setup
        }
        return copy
    }
}
