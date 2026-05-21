//
//  MatchTimelineHalfCell.swift
//  AppBase
//

import SnapKit
import UIKit

/// Card một hiệp: header (1ST HALF · 45:00) + các dòng timeline nối trục dọc.
final class MatchTimelineHalfCell: UITableViewCell {

    static let reuseId = "MatchTimelineHalfCell"

    private let cardView = UIView()
    private let headerTitleLabel = UILabel()
    private let headerDurationLabel = UILabel()
    private let eventsStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.backgroundColor = FootballPalette.surface
        cardView.layer.cornerRadius = Radius.s16
        cardView.clipsToBounds = true

        headerTitleLabel.font = FootballPalette.caption(12)
        headerTitleLabel.textColor = FootballPalette.textSecondary

        headerDurationLabel.font = FootballPalette.caption(12)
        headerDurationLabel.textColor = FootballPalette.textSecondary
        headerDurationLabel.textAlignment = .right

        eventsStack.axis = .vertical
        eventsStack.spacing = 0

        contentView.addSubview(cardView)
        cardView.addSubview(headerTitleLabel)
        cardView.addSubview(headerDurationLabel)
        cardView.addSubview(eventsStack)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(
                top: Spacing.s6,
                left: Spacing.s16,
                bottom: Spacing.s6,
                right: Spacing.s16
            ))
        }
        headerTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.s16)
        }
        headerDurationLabel.snp.makeConstraints { make in
            make.centerY.equalTo(headerTitleLabel)
            make.trailing.equalToSuperview().inset(Spacing.s16)
            make.leading.greaterThanOrEqualTo(headerTitleLabel.snp.trailing).offset(Spacing.s8)
        }
        eventsStack.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel.snp.bottom).offset(Spacing.s12)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        section: MatchTimelineSection,
        settings: FootballMatchSettings,
        homeName: String,
        awayName: String
    ) {
        headerTitleLabel.text = section.title
        headerDurationLabel.text = section.durationText

        eventsStack.arrangedSubviews.forEach {
            eventsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        guard !section.rows.isEmpty else {
            let empty = UILabel()
            empty.font = FootballPalette.caption()
            empty.textColor = FootballPalette.textSecondary
            empty.text = L10n.Football.Match.Timeline.emptyHalf
            empty.textAlignment = .center
            eventsStack.addArrangedSubview(empty)
            empty.snp.makeConstraints { make in
                make.height.equalTo(44)
            }
            return
        }

        for row in section.rows {
            let rowView = MatchTimelineEventRowView()
            rowView.configure(row: row, settings: settings, homeName: homeName, awayName: awayName)
            eventsStack.addArrangedSubview(rowView)
        }
    }
}
