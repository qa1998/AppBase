//
//  FootballGlassView.swift
//  AppBase
//

import UIKit
import SnapKit

/// Glassmorphism panel — blur + soft border + optional neon border.
class FootballGlassView: UIView {

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))

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
        applyFootballTheme()
        layer.cornerRadius = Radius.s16
        layer.masksToBounds = true
        addSubview(blurView)
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        borderLayer.borderWidth = 1
        borderLayer.cornerRadius = Radius.s16
        layer.addSublayer(borderLayer)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(footballThemeDidChange),
            name: .footballThemeDidChange,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func footballThemeDidChange() {
        applyFootballTheme()
    }

    func applyFootballTheme() {
        backgroundColor = FootballPalette.surface.withAlphaComponent(0.55)
        let isLight = ThemeManager.shared.mode == .light
        blurView.effect = UIBlurEffect(
            style: isLight ? .systemUltraThinMaterialLight : .systemUltraThinMaterialDark
        )
        updateBorder()
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
