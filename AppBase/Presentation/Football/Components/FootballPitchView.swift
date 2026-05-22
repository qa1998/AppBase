//
//  FootballPitchView.swift
//  AppBase
//

import UIKit

/// Football field with grid, white markings (edit lineup card).
final class FootballPitchView: UIView {

    static let fieldInset: CGFloat = 10
    /// Vertical pitch: field width / height ≈ 0.65
    static let fieldWidthToHeightRatio = PitchFormationGridLayout.fieldWidthToHeightRatio
    static let penaltyDepthRatio: CGFloat = 0.18

    var displayOptions: PitchDisplayOptions = LineupStore.shared.pitchDisplayOptions {
        didSet { setNeedsDisplay() }
    }

    func fieldRect(in bounds: CGRect? = nil) -> CGRect {
        (bounds ?? self.bounds).insetBy(dx: Self.fieldInset, dy: Self.fieldInset)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = FootballPalette.pitchGreen
        layer.cornerRadius = Radius.s12
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.withAlphaComponent(0.9).cgColor
        isOpaque = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let field = fieldRect(in: rect)

        if displayOptions.showsGrid {
            drawGrid(ctx: ctx, in: field)
        }

        let line = FootballPalette.pitchLine
        ctx.setStrokeColor(line.cgColor)
        ctx.setLineWidth(1.5)
        ctx.stroke(field)

        switch displayOptions.surfaceStyle {
        case .full:
            let midY = field.midY
            ctx.move(to: CGPoint(x: field.minX, y: midY))
            ctx.addLine(to: CGPoint(x: field.maxX, y: midY))
            ctx.strokePath()

            let centerRadius = min(field.width, field.height) * 0.11
            ctx.addEllipse(in: CGRect(
                x: field.midX - centerRadius,
                y: midY - centerRadius,
                width: centerRadius * 2,
                height: centerRadius * 2
            ))
            ctx.strokePath()

            drawPenaltyArea(ctx: ctx, field: field, top: true)
            drawPenaltyArea(ctx: ctx, field: field, top: false)
        case .half:
            let midY = field.midY
            ctx.move(to: CGPoint(x: field.minX, y: midY))
            ctx.addLine(to: CGPoint(x: field.maxX, y: midY))
            ctx.strokePath()
            drawPenaltyArea(ctx: ctx, field: field, top: true)
        case .futsal:
            let centerRadius = min(field.width, field.height) * 0.08
            ctx.addEllipse(in: CGRect(
                x: field.midX - centerRadius,
                y: field.midY - centerRadius,
                width: centerRadius * 2,
                height: centerRadius * 2
            ))
            ctx.strokePath()
        }
    }

    private func drawGrid(ctx: CGContext, in field: CGRect) {
        ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.08).cgColor)
        ctx.setLineWidth(0.5)
        let cols = 12
        let rows = 16
        for i in 1..<cols {
            let x = field.minX + field.width * CGFloat(i) / CGFloat(cols)
            ctx.move(to: CGPoint(x: x, y: field.minY))
            ctx.addLine(to: CGPoint(x: x, y: field.maxY))
        }
        for j in 1..<rows {
            let y = field.minY + field.height * CGFloat(j) / CGFloat(rows)
            ctx.move(to: CGPoint(x: field.minX, y: y))
            ctx.addLine(to: CGPoint(x: field.maxX, y: y))
        }
        ctx.strokePath()
    }

    private func drawPenaltyArea(ctx: CGContext, field: CGRect, top: Bool) {
        let w = field.width * 0.55
        let h = field.height * Self.penaltyDepthRatio
        let x = field.midX - w / 2
        let y = top ? field.minY : field.maxY - h
        ctx.stroke(CGRect(x: x, y: y, width: w, height: h))
    }
}
