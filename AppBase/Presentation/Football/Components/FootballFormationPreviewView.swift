//
//  FootballFormationPreviewView.swift
//  AppBase
//

import UIKit

/// Mini pitch preview for formation cards.
final class FootballFormationPreviewView: UIView {

    var formation: FootballFormation {
        didSet { setNeedsDisplay() }
    }

    init(formation: FootballFormation) {
        self.formation = formation
        super.init(frame: .zero)
        backgroundColor = FootballPalette.pitchGreen
        layer.cornerRadius = Radius.s8
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let inset: CGFloat = 4
        let field = rect.insetBy(dx: inset, dy: inset)
        ctx.setStrokeColor(FootballPalette.pitchLine.withAlphaComponent(0.5).cgColor)
        ctx.setLineWidth(0.5)
        ctx.stroke(field)

        ctx.setFillColor(FootballPalette.accentGreen.cgColor)
        for point in formation.slots {
            let x = field.minX + point.x * field.width
            let y = field.minY + point.y * field.height
            ctx.fillEllipse(in: CGRect(x: x - 2, y: y - 2, width: 4, height: 4))
        }
    }
}
