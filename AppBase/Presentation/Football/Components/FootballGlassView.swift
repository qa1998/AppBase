//
//  FootballGlassView.swift
//  AppBase
//

import UIKit
import SnapKit

/// Glassmorphism panel — blur + soft border + optional neon border.
final class FootballGlassView: UIView {

    private let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        return UIVisualEffectView(effect: effect)
    }()

    private let borderLayer = CALayer()

    var showsNeonBorder = false {
        didSet { updateBorder() }
    }

    var neonColor: UIColor = FootballPalette.accentGreen {
        didSet { updateBorder() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = FootballPalette.surface.withAlphaComponent(0.55)
        layer.cornerRadius = Radius.s16
        layer.masksToBounds = true
        addSubview(blurView)
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        borderLayer.borderWidth = 1
        borderLayer.cornerRadius = Radius.s16
        layer.addSublayer(borderLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = bounds
        borderLayer.cornerRadius = layer.cornerRadius
    }

    private func updateBorder() {
        if showsNeonBorder {
            borderLayer.borderColor = neonColor.cgColor
            layer.shadowColor = neonColor.cgColor
            layer.shadowOpacity = 0.55
            layer.shadowRadius = 10
            layer.shadowOffset = .zero
        } else {
            borderLayer.borderColor = FootballPalette.glassBorder.cgColor
            layer.shadowOpacity = 0
        }
    }
}
