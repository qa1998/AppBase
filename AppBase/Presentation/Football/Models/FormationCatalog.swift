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

    /// GK + outfield lines via dynamic pitch grid (normalized 0…1 in field space).
    static func makeSlots(lineCounts: [Int], totalPlayers: Int) -> [CGPoint] {
        PitchFormationGridLayout.normalizedCenters(lineCounts: lineCounts, totalPlayers: totalPlayers)
    }

    // MARK: - Pitch Y-axis (0 = attack / top, 1 = defense / GK bottom)

    static func flipPitchY(_ point: CGPoint) -> CGPoint {
        CGPoint(x: point.x, y: 1 - point.y)
    }

    /// GK is slot 0; inverted saves have GK `y` near the top.
    static func isPitchYAxisInverted(_ assignments: [PitchSlotAssignment]) -> Bool {
        guard let gkSlot = assignments.first else { return false }
        return gkSlot.normalizedPosition.y < 0.5
    }

    @discardableResult
    static func healInvertedPitch(_ lineup: inout FootballLineup) -> Bool {
        guard isPitchYAxisInverted(lineup.assignments) else { return false }
        lineup.assignments = lineup.assignments.map { slot in
            var copy = slot
            copy.normalizedPosition = flipPitchY(copy.normalizedPosition)
            return copy
        }
        lineup.tacticalDrawing = flipDrawingState(lineup.tacticalDrawing)
        return true
    }

    static func flipLineup(_ lineup: FootballLineup) -> FootballLineup {
        var copy = lineup
        _ = healInvertedPitch(&copy)
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

    @discardableResult
    static func healInvertedPitch(_ team: inout FootballTeam) -> Bool {
        var changed = false
        for key in team.setups.keys {
            guard var setup = team.setups[key] else { continue }
            guard isPitchYAxisInverted(setup.assignments) else { continue }
            setup.assignments = setup.assignments.map { slot in
                var s = slot
                s.normalizedPosition = flipPitchY(s.normalizedPosition)
                return s
            }
            team.setups[key] = setup
            changed = true
        }
        return changed
    }

    static func flipTeamSetups(_ team: FootballTeam) -> FootballTeam {
        var copy = team
        _ = healInvertedPitch(&copy)
        return copy
    }

    @discardableResult
    static func healInvertedPitch(_ roster: inout MatchTeamRoster) -> Bool {
        guard isPitchYAxisInverted(roster.assignments) else { return false }
        roster.assignments = roster.assignments.map { slot in
            var s = slot
            s.normalizedPosition = flipPitchY(s.normalizedPosition)
            return s
        }
        return true
    }
}
