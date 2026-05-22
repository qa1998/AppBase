//
//  PitchFormationGridLayout.swift
//  AppBase
//

import CoreGraphics
import UIKit

/// Dynamic grid placement for football formations on a vertical pitch.
/// FWD at top (row 0), GK at bottom (last row). Positions scale with field size.
enum PitchFormationGridLayout {

    /// Standard field width / height (vertical pitch: taller than wide).
    static let fieldWidthToHeightRatio: CGFloat = 0.65
    static let gridLayoutLineupsMigrationKey = "football.pitch.gridLayout.lineups.v3"
    static let gridLayoutTeamsMigrationKey = "football.pitch.gridLayout.teams.v3"
    static let gridLayoutMatchesMigrationKey = "football.pitch.gridLayout.matches.v3"

    struct Config {
        var horizontalPaddingRatio: CGFloat = 0.06
        var safeMarginRatio: CGFloat = 0.02
        var penaltyDepthRatio: CGFloat = 0.18
        var maxPlayerSize: CGFloat = 48
        var playerWidthFactor: CGFloat = 0.65
        var labelWidthFactor: CGFloat = 0.9
        var penaltyWidthRatio: CGFloat = 0.55
        /// GK vertical position inside own box (0 = top edge of box, 1 = goal line).
        var gkDepthInBoxRatio: CGFloat = 0.55

        static let `default` = Config()
    }

    /// Penalty areas aligned with `FootballPitchView` drawing.
    struct FieldZones: Equatable {
        let field: CGRect
        let opponentPenalty: CGRect
        let ownPenalty: CGRect
        /// Outfield rows between the two boxes (DEF → FWD).
        let outfieldTop: CGFloat
        let outfieldBottom: CGFloat
    }

    struct SlotPlacement: Equatable {
        let slotIndex: Int
        let rowIndex: Int
        let columnIndex: Int
        let playersInRow: Int
        let isGoalkeeper: Bool
        /// Center in pitch-view coordinates.
        let center: CGPoint
        let slotWidth: CGFloat
        let maxPlayerWidth: CGFloat
        let labelMaxWidth: CGFloat
        /// Normalized center within `fieldRect` (0…1).
        let normalizedCenter: CGPoint
    }

    // MARK: - Public

    static func placements(
        lineCounts: [Int],
        fieldRect: CGRect,
        totalPlayers: Int,
        config: Config = Config()
    ) -> [SlotPlacement] {
        let lines = normalizedLineCounts(lineCounts, totalPlayers: totalPlayers)
        guard fieldRect.width > 0, fieldRect.height > 0 else { return [] }

        let zones = fieldZones(in: fieldRect, config: config)
        let horizontalPadding = fieldRect.width * config.horizontalPaddingRatio

        var slots: [SlotPlacement] = []
        var slotIndex = 0

        // GK — inside own penalty box (home goal)
        let gkRowIndex = lines.count
        let gkCenterY = zones.ownPenalty.minY
            + zones.ownPenalty.height * config.gkDepthInBoxRatio

        appendRow(
            playersInRow: 1,
            rowIndex: gkRowIndex,
            centerY: gkCenterY,
            isGoalkeeper: true,
            fieldRect: fieldRect,
            horizontalPadding: horizontalPadding,
            config: config,
            slotIndex: &slotIndex,
            into: &slots
        )

        // Outfield: proportional from home goal → away goal (lineCounts[0] = DEF … last = FWD)
        let homeGoalY = zones.field.maxY
        let awayGoalY = zones.field.minY
        let span = homeGoalY - awayGoalY

        for (lineIndex, count) in lines.enumerated() {
            let rowIndex = lines.count - 1 - lineIndex
            let fraction = CGFloat(lineIndex + 1) / CGFloat(lines.count + 1)
            var centerY = homeGoalY - span * fraction
            centerY = clamp(
                centerY,
                min: zones.outfieldTop,
                max: zones.outfieldBottom
            )

            appendRow(
                playersInRow: count,
                rowIndex: rowIndex,
                centerY: centerY,
                isGoalkeeper: false,
                fieldRect: fieldRect,
                horizontalPadding: horizontalPadding,
                config: config,
                slotIndex: &slotIndex,
                into: &slots
            )
        }

        return slots.sorted { $0.slotIndex < $1.slotIndex }
    }

    static func fieldZones(in fieldRect: CGRect, config: Config = .default) -> FieldZones {
        let penaltyH = fieldRect.height * config.penaltyDepthRatio
        let safe = fieldRect.height * config.safeMarginRatio
        let penaltyW = fieldRect.width * config.penaltyWidthRatio
        let penaltyX = fieldRect.midX - penaltyW / 2

        let opponentPenalty = CGRect(
            x: penaltyX,
            y: fieldRect.minY,
            width: penaltyW,
            height: penaltyH
        )
        let ownPenalty = CGRect(
            x: penaltyX,
            y: fieldRect.maxY - penaltyH,
            width: penaltyW,
            height: penaltyH
        )

        return FieldZones(
            field: fieldRect,
            opponentPenalty: opponentPenalty,
            ownPenalty: ownPenalty,
            outfieldTop: opponentPenalty.maxY + safe,
            outfieldBottom: ownPenalty.minY - safe
        )
    }

    /// Normalized slot centers (0…1) inside a unit field for persistence / mini previews.
    static func normalizedCenters(lineCounts: [Int], totalPlayers: Int) -> [CGPoint] {
        let field = CGRect(x: 0, y: 0, width: fieldWidthToHeightRatio, height: 1)
        return placements(lineCounts: lineCounts, fieldRect: field, totalPlayers: totalPlayers)
            .sorted { $0.slotIndex < $1.slotIndex }
            .map(\.normalizedCenter)
    }

    static func placement(
        slotIndex: Int,
        formation: FootballFormation,
        fieldRect: CGRect,
        config: Config = Config()
    ) -> SlotPlacement? {
        let lines = formation.outfieldLineCounts
        let all = placements(lineCounts: lines, fieldRect: fieldRect, totalPlayers: formation.playerCount, config: config)
        return all.first { $0.slotIndex == slotIndex }
    }

    // MARK: - Row geometry

    private static func appendRow(
        playersInRow: Int,
        rowIndex: Int,
        centerY: CGFloat,
        isGoalkeeper: Bool,
        fieldRect: CGRect,
        horizontalPadding: CGFloat,
        config: Config,
        slotIndex: inout Int,
        into slots: inout [SlotPlacement]
    ) {
        let availableWidth = fieldRect.width - horizontalPadding * 2
        let count = max(playersInRow, 1)
        let slotWidth = availableWidth / CGFloat(count)

        for column in 0..<count {
            var centerX = fieldRect.minX
                + horizontalPadding
                + slotWidth * CGFloat(column)
                + slotWidth / 2

            let maxPlayerWidth = min(slotWidth * config.playerWidthFactor, config.maxPlayerSize)
            let labelMaxWidth = slotWidth * config.labelWidthFactor
            let radius = maxPlayerWidth / 2

            centerX = clamp(
                centerX,
                min: fieldRect.minX + horizontalPadding + radius,
                max: fieldRect.maxX - horizontalPadding - radius
            )
            var clampedY = clamp(
                centerY,
                min: fieldRect.minY + radius,
                max: fieldRect.maxY - radius
            )

            let normalized = CGPoint(
                x: (centerX - fieldRect.minX) / fieldRect.width,
                y: (clampedY - fieldRect.minY) / fieldRect.height
            )

            slots.append(
                SlotPlacement(
                    slotIndex: slotIndex,
                    rowIndex: rowIndex,
                    columnIndex: column,
                    playersInRow: count,
                    isGoalkeeper: isGoalkeeper,
                    center: CGPoint(x: centerX, y: clampedY),
                    slotWidth: slotWidth,
                    maxPlayerWidth: maxPlayerWidth,
                    labelMaxWidth: labelMaxWidth,
                    normalizedCenter: normalized
                )
            )
            slotIndex += 1
        }
    }

    /// Rebuilds assignment coordinates from formation grid (normalized field space).
    static func realignAssignments(
        _ assignments: [PitchSlotAssignment],
        formation: FootballFormation
    ) -> [PitchSlotAssignment] {
        let centers = normalizedCenters(
            lineCounts: formation.outfieldLineCounts,
            totalPlayers: formation.playerCount
        )
        return assignments.enumerated().map { index, slot in
            var copy = slot
            if index < centers.count {
                copy.normalizedPosition = centers[index]
            }
            return copy
        }
    }

    static func normalizedLineCounts(_ lineCounts: [Int], totalPlayers: Int) -> [Int] {
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
        return lines
    }

    private static func clamp(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, minValue), maxValue)
    }
}

// MARK: - Formation

extension FootballFormation {

    /// Outfield lines from formation name (e.g. 4-3-3 → [4, 3, 3], DEF → FWD).
    var outfieldLineCounts: [Int] {
        name.split(separator: "-").compactMap { Int($0) }
    }

    func gridPlacements(in fieldRect: CGRect) -> [PitchFormationGridLayout.SlotPlacement] {
        PitchFormationGridLayout.placements(
            lineCounts: outfieldLineCounts,
            fieldRect: fieldRect,
            totalPlayers: playerCount
        )
    }

    static func lineCounts(from name: String) -> [Int] {
        name.split(separator: "-").compactMap { Int($0) }
    }
}
