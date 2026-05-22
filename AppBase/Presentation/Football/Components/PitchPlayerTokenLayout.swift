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
        guard pitchBounds.width > 0, pitchBounds.height > 0, !tokens.isEmpty else { return }

        let field = pitchView.fieldRect(in: pitchBounds)
        let zones = PitchFormationGridLayout.fieldZones(in: field)
        let placements = formation.gridPlacements(in: field)
        let placementBySlot = Dictionary(uniqueKeysWithValues: placements.map { ($0.slotIndex, $0) })

        var rowGroups: [Int: [(token: FootballPlayerTokenView, placement: PitchFormationGridLayout.SlotPlacement)]] = [:]

        for token in tokens {
            guard let placement = placementBySlot[token.slotIndex] else { continue }
            token.gridLabelMaxWidth = placement.labelMaxWidth
            token.gridMaxCircleDiameter = placement.maxPlayerWidth
            token.normalizedPosition = placement.normalizedCenter
            rowGroups[placement.rowIndex, default: []].append((token, placement))
        }

        for rowItems in rowGroups.values {
            let sizes = rowItems.map { item -> CGSize in
                item.token.setNeedsLayout()
                item.token.layoutIfNeeded()
                return item.token.preferredTokenSize
            }
            let rowHeight = sizes.map(\.height).max() ?? 0

            for (item, size) in zip(rowItems, sizes) {
                let center = item.placement.center
                let halfW = size.width / 2
                let halfH = rowHeight / 2

                let clampedCenter = clampCenter(
                    proposed: center,
                    halfWidth: halfW,
                    halfHeight: halfH,
                    field: field,
                    zones: zones,
                    isGoalkeeper: item.placement.isGoalkeeper,
                    horizontalPadding: field.width * PitchFormationGridLayout.Config.default.horizontalPaddingRatio
                )

                let offsetX = clampedCenter.x - pitchBounds.width / 2
                let offsetY = clampedCenter.y - pitchBounds.height / 2

                item.token.snp.remakeConstraints { make in
                    make.width.equalTo(size.width)
                    make.height.equalTo(rowHeight)
                    make.centerX.equalToSuperview().offset(offsetX)
                    make.centerY.equalToSuperview().offset(offsetY)
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
        zones: PitchFormationGridLayout.FieldZones,
        isGoalkeeper: Bool,
        horizontalPadding: CGFloat
    ) -> CGPoint {
        let minX = field.minX + horizontalPadding + halfWidth
        let maxX = field.maxX - horizontalPadding - halfWidth

        let minY: CGFloat
        let maxY: CGFloat
        if isGoalkeeper {
            minY = zones.ownPenalty.minY + halfHeight
            maxY = zones.field.maxY - halfHeight
        } else {
            minY = zones.outfieldTop + halfHeight
            maxY = zones.outfieldBottom - halfHeight
        }

        return CGPoint(
            x: min(max(proposed.x, minX), maxX),
            y: min(max(proposed.y, minY), maxY)
        )
    }
}
