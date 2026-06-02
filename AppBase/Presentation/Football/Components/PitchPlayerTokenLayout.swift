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
        centerGapRatio: CGFloat = 0.05
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
            mirrorVertically: false,
            spreadRowsAcrossWidth: true
        )
    }

    private static func applyPlacements(
        tokens: [FootballPlayerTokenView],
        placements: [PitchFormationGridLayout.SlotPlacement],
        pitchView: FootballPitchView,
        fieldRect: CGRect,
        mirrorVertically: Bool,
        spreadRowsAcrossWidth: Bool = false
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

        let sortedRowKeys = rowGroups.keys.sorted()
        for rowKey in sortedRowKeys {
            guard var rowItems = rowGroups[rowKey] else { continue }
            rowItems.sort { $0.placement.columnIndex < $1.placement.columnIndex }

            let sizes = rowItems.map { item -> CGSize in
                item.token.setNeedsLayout()
                item.token.layoutIfNeeded()
                return item.token.preferredTokenSize
            }

            let centersX: [CGFloat]
            if spreadRowsAcrossWidth {
                centersX = spreadRowCentersX(
                    tokenWidths: sizes.map(\.width),
                    in: fieldRect,
                    horizontalPadding: horizontalPadding
                )
            } else {
                centersX = rowItems.map(\.placement.center.x)
            }

            for (index, item) in rowItems.enumerated() {
                let size = sizes[index]
                let halfW = size.width / 2
                let halfH = rowHeight / 2

                var centerX = centersX[index]
                var centerY = item.placement.center.y

                centerX = min(
                    max(centerX, fieldRect.minX + horizontalPadding + halfW),
                    fieldRect.maxX - horizontalPadding - halfW
                )
                centerY = min(
                    max(centerY, fieldRect.minY + verticalPadding + halfH),
                    fieldRect.maxY - verticalPadding - halfH
                )

                let center = mirrorVertically
                    ? CGPoint(
                        x: centerX,
                        y: fieldRect.minY + fieldRect.maxY - centerY
                    )
                    : CGPoint(x: centerX, y: centerY)

                item.token.snp.remakeConstraints { make in
                    make.width.equalTo(size.width)
                    make.height.equalTo(rowHeight)
                    make.leading.equalTo(pitchView).offset(center.x - size.width / 2)
                    make.top.equalTo(pitchView).offset(center.y - rowHeight / 2)
                }
            }
        }
    }

    /// Trải token một hàng từ mép trái → phải nửa sân (có gap tối thiểu).
    private static func spreadRowCentersX(
        tokenWidths: [CGFloat],
        in fieldRect: CGRect,
        horizontalPadding: CGFloat
    ) -> [CGFloat] {
        let count = tokenWidths.count
        guard count > 0 else { return [] }
        if count == 1 { return [fieldRect.midX] }

        let minGap: CGFloat = 8
        let available = fieldRect.width - horizontalPadding * 2
        let totalWidth = tokenWidths.reduce(0, +) + minGap * CGFloat(count - 1)

        if totalWidth <= available {
            var leading = fieldRect.minX + horizontalPadding + (available - totalWidth) / 2
            return tokenWidths.map { width in
                let center = leading + width / 2
                leading += width + minGap
                return center
            }
        }

        return (0..<count).map { index in
            let slot = available / CGFloat(count)
            return fieldRect.minX + horizontalPadding + slot * (CGFloat(index) + 0.5)
        }
    }

}
