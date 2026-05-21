//
//  LineupMiniPitchView.swift
//  AppBase
//

import UIKit

/// Compact tactical preview for lineup list cards.
final class LineupMiniPitchView: UIView {

    var lineup: FootballLineup? {
        didSet { setNeedsDisplay() }
    }

    /// Preview khi không có full `FootballLineup` (vd. team list).
    var assignments: [PitchSlotAssignment] = [] {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = FootballPalette.surfaceElevated
        layer.cornerRadius = Radius.s8
        isOpaque = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let slots = lineup?.assignments ?? assignments
        guard !slots.isEmpty else { return }
        let inset: CGFloat = 6
        let field = rect.insetBy(dx: inset, dy: inset)

        FootballPalette.pitchGreen.setFill()
        UIBezierPath(roundedRect: field, cornerRadius: 4).fill()

        for (index, assignment) in slots.enumerated() {
            let point = assignment.normalizedPosition
            let x = field.minX + point.x * field.width
            let y = field.minY + point.y * field.height
            let isGK = assignment.player?.position == .gk || index == 0
            let color = isGK ? FootballPalette.accentRed : FootballPalette.accentGreen
            color.setFill()
            UIBezierPath(
                ovalIn: CGRect(x: x - 3, y: y - 3, width: 6, height: 6)
            ).fill()
        }
    }
}
