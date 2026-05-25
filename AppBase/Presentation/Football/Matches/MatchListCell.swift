//
//  MatchListCell.swift
//  AppBase
//

import SnapKit
import UIKit

final class MatchListCell: UITableViewCell {

    static let reuseId = "MatchListCell"

    private let card = UIView()
    private let homeLabel = UILabel()
    private let awayLabel = UILabel()
    private let scoreLabel = UILabel()
    private let dateLabel = UILabel()
    private let phaseLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear

        card.backgroundColor = FootballPalette.surface
        card.layer.cornerRadius = Radius.s12

        homeLabel.font = FootballPalette.title(16)
        homeLabel.textColor = FootballPalette.textPrimary

        awayLabel.font = FootballPalette.title(16)
        awayLabel.textColor = FootballPalette.textPrimary

        scoreLabel.font = FootballPalette.headline(20)
        scoreLabel.textColor = FootballPalette.accentGreen
        scoreLabel.textAlignment = .center

        dateLabel.font = FootballPalette.caption()
        dateLabel.textColor = FootballPalette.textSecondary

        phaseLabel.font = FootballPalette.caption(11)
        phaseLabel.textColor = FootballPalette.accentRed

        contentView.addSubview(card)
        card.addSubview(homeLabel)
        card.addSubview(scoreLabel)
        card.addSubview(awayLabel)
        card.addSubview(dateLabel)
        card.addSubview(phaseLabel)

        card.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)) }
        homeLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.s16)
            make.trailing.lessThanOrEqualTo(scoreLabel.snp.leading).offset(-Spacing.s8)
        }
        scoreLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(homeLabel)
            make.width.equalTo(56)
        }
        awayLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(Spacing.s16)
            make.leading.greaterThanOrEqualTo(scoreLabel.snp.trailing).offset(Spacing.s8)
        }
        dateLabel.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(Spacing.s16)
            make.top.equalTo(homeLabel.snp.bottom).offset(Spacing.s8)
        }
        phaseLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(Spacing.s16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(match: FootballMatch) {
        homeLabel.text = match.settings.homeTeam
        awayLabel.text = match.settings.awayTeam
        scoreLabel.text = match.scoreLine
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: match.settings.kickoffDate)
        phaseLabel.text = phaseShort(match.phase)
    }

    func applyTheme() {
        card.backgroundColor = FootballPalette.surface
        homeLabel.textColor = FootballPalette.textPrimary
        awayLabel.textColor = FootballPalette.textPrimary
        scoreLabel.textColor = FootballPalette.accentGreen
        dateLabel.textColor = FootballPalette.textSecondary
        phaseLabel.textColor = FootballPalette.accentRed
    }

    private func phaseShort(_ phase: MatchPhase) -> String {
        switch phase {
        case .scheduled: return L10n.Football.Match.Phase.scheduled
        case .finished: return L10n.Football.Match.Phase.finished
        default: return L10n.Football.Match.Phase.live
        }
    }
}
