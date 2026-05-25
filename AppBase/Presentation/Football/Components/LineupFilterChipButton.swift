//
//  LineupFilterChipButton.swift
//  AppBase
//

import UIKit

final class LineupFilterChipButton: UIButton {

    override var isSelected: Bool {
        didSet { applyStyle() }
    }

    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = FootballPalette.caption(13)
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        layer.cornerRadius = 18
        applyStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyStyle() {
        if isSelected {
            backgroundColor = FootballPalette.accentGreen
            setTitleColor(FootballPalette.onAccent, for: .normal)
        } else {
            backgroundColor = FootballPalette.surfaceElevated
            setTitleColor(FootballPalette.textPrimary, for: .normal)
        }
    }
}
