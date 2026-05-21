//
//  TacticalDrawingOverlay.swift
//  AppBase
//

import UIKit

/// Coach-board overlay for tactical arrows and zones.
final class TacticalDrawingOverlay: UIView {

    var strokes: [TacticalStroke] = [] {
        didSet { setNeedsDisplay() }
    }

    var lineOptions: TacticalLineOptions = LineupStore.shared.tacticalLineOptions {
        didSet { setNeedsDisplay() }
    }

    var onStrokeWillCommit: (() -> Void)?
    var onStrokeCommitted: (() -> Void)?
    /// When set, taps on player tokens pass through so picks still work under the overlay.
    weak var passThroughHost: UIView?
    private var currentPoints: [CGPoint] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleDraw(_:)))
        addGestureRecognizer(pan)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden, isUserInteractionEnabled, alpha > 0.01 else { return nil }
        guard bounds.contains(point) else { return nil }

        if let host = passThroughHost {
            for subview in host.subviews.reversed() where subview !== self {
                let local = convert(point, to: subview)
                guard subview.point(inside: local, with: event) else { continue }
                if let hit = subview.hitTest(local, with: event),
                   hit is FootballPlayerTokenView || hit.hasAncestor(of: FootballPlayerTokenView.self) {
                    return nil
                }
            }
        }
        return self
    }

    func clear() {
        strokes.removeAll()
        currentPoints.removeAll()
        LineupStore.shared.clearTacticalDrawings()
        setNeedsDisplay()
    }

    @objc private func handleDraw(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: self)
        switch gesture.state {
        case .began:
            currentPoints = [point]
        case .changed:
            updateCurrentPoints(with: point)
            setNeedsDisplay()
        case .ended, .cancelled:
            updateCurrentPoints(with: point)
            let committed = Self.normalizedPoints(from: currentPoints, pathType: lineOptions.pathType)
            guard committed.count > 1 else {
                currentPoints.removeAll()
                setNeedsDisplay()
                return
            }
            let stroke = TacticalStroke(points: committed, options: lineOptions)
            onStrokeWillCommit?()
            strokes.append(stroke)
            LineupStore.shared.setTacticalStrokes(strokes)
            currentPoints.removeAll()
            setNeedsDisplay()
            onStrokeCommitted?()
        default:
            break
        }
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        let previewStroke = currentPoints.isEmpty
            ? nil
            : TacticalStroke(points: currentPoints, options: lineOptions)
        let all = strokes + (previewStroke.map { [$0] } ?? [])

        for stroke in all {
            drawStroke(stroke, in: ctx)
        }
    }

    private func drawStroke(_ stroke: TacticalStroke, in ctx: CGContext) {
        let options = stroke.options
        let pathPoints = Self.resolvedPoints(for: stroke.points, pathType: options.pathType)
        guard let first = pathPoints.first else { return }

        ctx.saveGState()
        ctx.setStrokeColor(options.color.uiColor.cgColor)
        ctx.setLineWidth(2.5)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        if options.lineStyle == .dashed {
            ctx.setLineDash(phase: 0, lengths: [6, 4])
        }

        ctx.beginPath()
        ctx.move(to: first)
        for point in pathPoints.dropFirst() {
            ctx.addLine(to: point)
        }
        ctx.strokePath()

        if pathPoints.count > 1, options.pointer != .none {
            let from = pathPoints[pathPoints.count - 2]
            let to = pathPoints[pathPoints.count - 1]
            drawPointer(ctx: ctx, from: from, to: to, pointer: options.pointer, color: options.color.uiColor)
        }
        ctx.restoreGState()
    }

    private func drawPointer(
        ctx: CGContext,
        from: CGPoint,
        to: CGPoint,
        pointer: TacticalLinePointer,
        color: UIColor
    ) {
        ctx.setStrokeColor(color.cgColor)
        ctx.setFillColor(color.cgColor)
        let angle = atan2(to.y - from.y, to.x - from.x)
        let size: CGFloat = 10

        switch pointer {
        case .arrow:
            drawArrowHead(ctx: ctx, to: to, angle: angle, size: size, filled: true)
        case .hollowArrow:
            drawArrowHead(ctx: ctx, to: to, angle: angle, size: size, filled: false)
        case .diamond:
            let s: CGFloat = 7
            ctx.beginPath()
            ctx.move(to: CGPoint(x: to.x, y: to.y - s))
            ctx.addLine(to: CGPoint(x: to.x + s, y: to.y))
            ctx.addLine(to: CGPoint(x: to.x, y: to.y + s))
            ctx.addLine(to: CGPoint(x: to.x - s, y: to.y))
            ctx.closePath()
            ctx.strokePath()
        case .bar:
            let nx = -sin(angle)
            let ny = cos(angle)
            let half: CGFloat = 8
            ctx.beginPath()
            ctx.move(to: CGPoint(x: to.x - nx * half, y: to.y - ny * half))
            ctx.addLine(to: CGPoint(x: to.x + nx * half, y: to.y + ny * half))
            ctx.strokePath()
        case .cross:
            let s: CGFloat = 6
            ctx.beginPath()
            ctx.move(to: CGPoint(x: to.x - s, y: to.y - s))
            ctx.addLine(to: CGPoint(x: to.x + s, y: to.y + s))
            ctx.move(to: CGPoint(x: to.x + s, y: to.y - s))
            ctx.addLine(to: CGPoint(x: to.x - s, y: to.y + s))
            ctx.strokePath()
        case .none:
            break
        }
    }

    private func drawArrowHead(ctx: CGContext, to: CGPoint, angle: CGFloat, size: CGFloat, filled: Bool) {
        let p1 = CGPoint(
            x: to.x - size * cos(angle - .pi / 6),
            y: to.y - size * sin(angle - .pi / 6)
        )
        let p2 = CGPoint(
            x: to.x - size * cos(angle + .pi / 6),
            y: to.y - size * sin(angle + .pi / 6)
        )
        ctx.beginPath()
        ctx.move(to: to)
        ctx.addLine(to: p1)
        ctx.move(to: to)
        ctx.addLine(to: p2)
        ctx.strokePath()
        if filled {
            ctx.beginPath()
            ctx.move(to: to)
            ctx.addLine(to: p1)
            ctx.addLine(to: p2)
            ctx.closePath()
            ctx.fillPath()
        }
    }

    private func updateCurrentPoints(with point: CGPoint) {
        switch lineOptions.pathType {
        case .straight:
            guard let start = currentPoints.first else {
                currentPoints = [point]
                return
            }
            currentPoints = [start, point]
        case .curved:
            if currentPoints.isEmpty {
                currentPoints = [point]
            } else {
                currentPoints.append(point)
            }
        }
    }

    /// Straight: start → end only. Curved: freehand path as drawn.
    static func normalizedPoints(from points: [CGPoint], pathType: TacticalPathType) -> [CGPoint] {
        guard points.count >= 2,
              let start = points.first,
              let end = points.last else { return points }

        switch pathType {
        case .straight:
            return [start, end]
        case .curved:
            return points
        }
    }

    static func resolvedPoints(for points: [CGPoint], pathType: TacticalPathType) -> [CGPoint] {
        normalizedPoints(from: points, pathType: pathType)
    }
}

private extension UIView {
    func hasAncestor(of type: UIView.Type) -> Bool {
        var view: UIView? = superview
        while let current = view {
            if current.isKind(of: type) { return true }
            view = current.superview
        }
        return false
    }
}
