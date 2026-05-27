//
//  PitchPlayerTokenLayout.swift
//  AppBase
//

import SnapKit
import UIKit

/// Places player tokens on a pitch using `PitchFormationGridLayout`.
enum PitchPlayerTokenLayout {

    static func layout(
        _ tokens: [FootballPlayerTokenView],
        formation: FootballFormation,
        in pitchView: FootballPitchView
    ) {
        let pitchBounds = pitchView.bounds
        guard pitchBounds.width > 0, pitchBounds.height > 0 else { return }
        let field = pitchView.fieldRect(in: pitchBounds)
        layout(
            tokens,
            formation: formation,
            in: pitchView,
            fieldRect: field,
            mirrorVertically: false
        )
    }

    /// Một sân dọc: đội nhà nửa trên (GK mép trên), đội khách nửa dưới (GK mép dưới).
    static func layoutCombined(
        homeTokens: [FootballPlayerTokenView],
        homeFormation: FootballFormation,
        awayTokens: [FootballPlayerTokenView],
        awayFormation: FootballFormation,
        in pitchView: FootballPitchView,
        centerGapRatio: CGFloat = 0.06
    ) {
        let pitchBounds = pitchView.bounds
        guard pitchBounds.width > 0, pitchBounds.height > 0 else { return }

        let field = pitchView.fieldRect(in: pitchBounds)
        let gap = field.height * centerGapRatio
        let halfH = (field.height - gap) / 2
        let topHalf = CGRect(x: field.minX, y: field.minY, width: field.width, height: halfH)
        let bottomHalf = CGRect(
            x: field.minX,
            y: field.minY + halfH + gap,
            width: field.width,
            height: halfH
        )

        layoutHalf(
            homeTokens,
            formation: homeFormation,
            in: pitchView,
            halfRect: topHalf,
            goalAtTop: true
        )
        layoutHalf(
            awayTokens,
            formation: awayFormation,
            in: pitchView,
            halfRect: bottomHalf,
            goalAtTop: false
        )
    }

    // MARK: - Field rect

    private static func layout(
        _ tokens: [FootballPlayerTokenView],
        formation: FootballFormation,
        in pitchView: FootballPitchView,
        fieldRect: CGRect,
        mirrorVertically: Bool
    ) {
        let placements = formation.gridPlacements(in: fieldRect)
        applyPlacements(
            tokens: tokens,
            placements: placements,
            pitchView: pitchView,
            fieldRect: fieldRect,
            mirrorVertically: mirrorVertically
        )
    }

    private static func layoutHalf(
        _ tokens: [FootballPlayerTokenView],
        formation: FootballFormation,
        in pitchView: FootballPitchView,
        halfRect: CGRect,
        goalAtTop: Bool
    ) {
        let placements = PitchFormationGridLayout.placementsForHalf(
            lineCounts: formation.outfieldLineCounts,
            halfRect: halfRect,
            totalPlayers: formation.playerCount,
            goalAtTop: goalAtTop
        )
        applyPlacements(
            tokens: tokens,
            placements: placements,
            pitchView: pitchView,
            fieldRect: halfRect,
            mirrorVertically: false
        )
    }

    private static func applyPlacements(
        tokens: [FootballPlayerTokenView],
        placements: [PitchFormationGridLayout.SlotPlacement],
        pitchView: FootballPitchView,
        fieldRect: CGRect,
        mirrorVertically: Bool
    ) {
        guard fieldRect.width > 0, fieldRect.height > 0, !tokens.isEmpty else { return }

        let placementBySlot = Dictionary(uniqueKeysWithValues: placements.map { ($0.slotIndex, $0) })

        var rowGroups: [Int: [(token: FootballPlayerTokenView, placement: PitchFormationGridLayout.SlotPlacement)]] = [:]

        for token in tokens {
            guard let placement = placementBySlot[token.slotIndex] else { continue }
            token.gridLabelMaxWidth = placement.labelMaxWidth
            token.normalizedPosition = placement.normalizedCenter
            rowGroups[placement.rowIndex, default: []].append((token, placement))
        }

        let rowHeight = FootballPlayerTokenSize.pitch.fixedTokenHeight
        let horizontalPadding = fieldRect.width * PitchFormationGridLayout.Config.default.horizontalPaddingRatio
        let verticalPadding = fieldRect.height * 0.04

        for rowItems in rowGroups.values {
            let sizes = rowItems.map { item -> CGSize in
                item.token.setNeedsLayout()
                item.token.layoutIfNeeded()
                return item.token.preferredTokenSize
            }

            for (item, size) in zip(rowItems, sizes) {
                let halfW = size.width / 2
                let halfH = rowHeight / 2

                let clampedCenter = clampCenter(
                    proposed: item.placement.center,
                    halfWidth: halfW,
                    halfHeight: halfH,
                    field: fieldRect,
                    isGoalkeeper: item.placement.isGoalkeeper,
                    horizontalPadding: horizontalPadding,
                    verticalPadding: verticalPadding
                )

                let center = mirrorVertically
                    ? CGPoint(
                        x: clampedCenter.x,
                        y: fieldRect.minY + fieldRect.maxY - clampedCenter.y
                    )
                    : clampedCenter

                item.token.snp.remakeConstraints { make in
                    make.width.equalTo(size.width)
                    make.height.equalTo(rowHeight)
                    make.leading.equalTo(pitchView).offset(center.x - size.width / 2)
                    make.top.equalTo(pitchView).offset(center.y - rowHeight / 2)
                }
            }
        }
    }

    // MARK: - Private

    private static func clampCenter(
        proposed: CGPoint,
        halfWidth: CGFloat,
        halfHeight: CGFloat,
        field: CGRect,
        isGoalkeeper: Bool,
        horizontalPadding: CGFloat,
        verticalPadding: CGFloat
    ) -> CGPoint {
        let minX = field.minX + horizontalPadding + halfWidth
        let maxX = field.maxX - horizontalPadding - halfWidth

        let minY: CGFloat
        let maxY: CGFloat
        if isGoalkeeper {
            minY = field.minY + verticalPadding + halfHeight
            maxY = field.maxY - verticalPadding - halfHeight
        } else {
            minY = field.minY + verticalPadding + halfHeight
            maxY = field.maxY - verticalPadding - halfHeight
        }

        return CGPoint(
            x: min(max(proposed.x, minX), maxX),
            y: min(max(proposed.y, minY), maxY)
        )
    }
}
