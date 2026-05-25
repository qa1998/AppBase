//
//  MatchPitchSizeButton.swift
//  AppBase
//

import SnapKit
import UIKit

final class MatchPitchSizeButton: UIControl {

    let pitchSize: MatchPitchSize
    private let titleLabel = UILabel()

    override var isSelected: Bool {
        didSet { refresh() }
    }

    init(size: MatchPitchSize) {
        pitchSize = size
        super.init(frame: .zero)
        backgroundColor = FootballPalette.surface
        layer.cornerRadius = Radius.s12
        refreshTitle()
        titleLabel.font = FootballPalette.title(15)
        titleLabel.textAlignment = .center
        titleLabel.isUserInteractionEnabled = false
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(Spacing.s12) }
        snp.makeConstraints { $0.height.equalTo(44) }
        refresh()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refreshTitle() {
        titleLabel.text = L10n.Football.Match.Create.pitchPlayers(pitchSize.playerCount)
    }

    func refresh() {
        backgroundColor = FootballPalette.surface
        layer.borderWidth = isSelected ? 2 : 0
        layer.borderColor = FootballPalette.accentGreen.cgColor
        titleLabel.textColor = isSelected ? FootballPalette.textPrimary : FootballPalette.textSecondary
    }
}
