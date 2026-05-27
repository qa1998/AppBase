//
//  MatchLiveScoreboardView.swift
//  AppBase
//

import SnapKit
import UIKit

/// Scoreboard gọn — đội trái/phải, tỉ số & đồng hồ giữa.
final class MatchLiveScoreboardView: UIView {

    private let card = UIView()
    private let homeColumn = MatchLiveTeamColumnView()
    private let awayColumn = MatchLiveTeamColumnView()
    private let centerStack = UIStackView()
    private let phasePill = UILabel()
    private let scoreLabel = UILabel()
    private let clockLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        homeName: String,
        awayName: String,
        homeCount: Int,
        awayCount: Int,
        scoreText: String,
        phaseText: String,
        clockText: String,
        isFinished: Bool
    ) {
        homeColumn.configure(name: homeName, playerCount: homeCount)
        awayColumn.configure(name: awayName, playerCount: awayCount)
        phasePill.text = phaseText.uppercased()
        scoreLabel.text = scoreText
        clockLabel.text = clockText
        clockLabel.font = FootballPalette.headline(isFinished ? 22 : 28)
        clockLabel.alpha = isFinished ? 0.85 : 1
    }

    func applyTheme() {
        card.backgroundColor = FootballPalette.surface
        card.layer.borderColor = FootballPalette.glassBorder.cgColor
        scoreLabel.textColor = FootballPalette.accentGreen
        clockLabel.textColor = FootballPalette.textPrimary
        phasePill.textColor = FootballPalette.textSecondary
        phasePill.backgroundColor = FootballPalette.surfaceElevated
        homeColumn.applyTheme()
        awayColumn.applyTheme()
    }

    private func build() {
        card.backgroundColor = FootballPalette.surface
        card.layer.cornerRadius = Radius.s16
        card.layer.borderWidth = 1

        phasePill.font = FootballPalette.caption(10)
        phasePill.textColor = FootballPalette.textSecondary
        phasePill.backgroundColor = FootballPalette.surfaceElevated
        phasePill.layer.cornerRadius = 8
        phasePill.clipsToBounds = true
        phasePill.textAlignment = .center

        scoreLabel.font = FootballPalette.headline(34)
        scoreLabel.textColor = FootballPalette.accentGreen
        scoreLabel.textAlignment = .center
        scoreLabel.adjustsFontSizeToFitWidth = true
        scoreLabel.minimumScaleFactor = 0.7

        clockLabel.font = FootballPalette.headline(28)
        clockLabel.textColor = FootballPalette.textPrimary
        clockLabel.textAlignment = .center

        centerStack.axis = .vertical
        centerStack.alignment = .center
        centerStack.spacing = Spacing.s4
        centerStack.addArrangedSubview(phasePill)
        centerStack.addArrangedSubview(scoreLabel)
        centerStack.addArrangedSubview(clockLabel)

        phasePill.snp.makeConstraints { $0.height.equalTo(20) }

        addSubview(card)
        card.addSubview(homeColumn)
        card.addSubview(centerStack)
        card.addSubview(awayColumn)

        card.snp.makeConstraints { $0.edges.equalToSuperview() }
        homeColumn.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(Spacing.s14)
            make.width.equalTo(76)
        }
        awayColumn.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview().inset(Spacing.s14)
            make.width.equalTo(76)
        }
        centerStack.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(homeColumn.snp.trailing).offset(Spacing.s8)
            make.trailing.equalTo(awayColumn.snp.leading).offset(-Spacing.s8)
        }
    }
}

// MARK: - Team column

private final class MatchLiveTeamColumnView: UIView {

    private let countLabel = UILabel()
    private let circle = UIView()
    private let initialsLabel = UILabel()
    private let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        countLabel.font = FootballPalette.caption(10)
        countLabel.textAlignment = .center

        circle.layer.cornerRadius = 22
        circle.layer.borderWidth = 1

        initialsLabel.font = FootballPalette.title(12)
        initialsLabel.textAlignment = .center

        nameLabel.font = FootballPalette.caption(11)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2

        addSubview(circle)
        circle.addSubview(initialsLabel)
        addSubview(countLabel)
        addSubview(nameLabel)

        circle.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(44)
        }
        initialsLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(circle.snp.bottom).offset(Spacing.s4)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(2)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(name: String, playerCount: Int) {
        countLabel.text = "\(playerCount)"
        nameLabel.text = name
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map { String($0) }
        initialsLabel.text = letters.joined().uppercased().isEmpty ? "?" : letters.joined().uppercased()
    }

    func applyTheme() {
        countLabel.textColor = FootballPalette.textSecondary
        nameLabel.textColor = FootballPalette.textPrimary
        initialsLabel.textColor = FootballPalette.textPrimary
        circle.backgroundColor = FootballPalette.surfaceElevated
        circle.layer.borderColor = FootballPalette.glassBorder.cgColor
    }
}
