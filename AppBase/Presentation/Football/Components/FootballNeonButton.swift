//
//  FootballNeonButton.swift
//  AppBase
//

import UIKit
import SnapKit

enum FootballButtonStyle {
    case primary
    case secondary
    case destructive
    case ghost
}

final class FootballNeonButton: UIButton {

    private let style: FootballButtonStyle

    init(title: String, style: FootballButtonStyle = .primary) {
        self.style = style
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = FootballPalette.caption(14)
        layer.cornerRadius = Radius.s12
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        applyStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func applyStyle() {
        switch style {
        case .primary:
            backgroundColor = FootballPalette.accentGreen
            setTitleColor(FootballPalette.background, for: .normal)
            layer.shadowColor = FootballPalette.neonGlowGreen.cgColor
            layer.shadowOpacity = 0.8
            layer.shadowRadius = 8
        case .secondary:
            backgroundColor = FootballPalette.surfaceElevated
            setTitleColor(FootballPalette.textPrimary, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = FootballPalette.glassBorder.cgColor
        case .destructive:
            backgroundColor = FootballPalette.accentRed.withAlphaComponent(0.2)
            setTitleColor(FootballPalette.accentRed, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = FootballPalette.accentRed.withAlphaComponent(0.5).cgColor
        case .ghost:
            backgroundColor = .clear
            setTitleColor(FootballPalette.textSecondary, for: .normal)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.75 : 1
            transform = isHighlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
        }
    }
}
