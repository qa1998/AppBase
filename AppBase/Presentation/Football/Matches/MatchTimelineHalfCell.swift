//
//  MatchTimelineHalfCell.swift
//  AppBase
//

import SnapKit
import UIKit

/// Header hiệp + các dòng timeline (trục giữa).
final class MatchTimelineHalfCell: UITableViewCell {

    static let reuseId = "MatchTimelineHalfCell"

    private let headerTitleLabel = UILabel()
    private let headerDurationLabel = UILabel()
    private let eventsStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        headerTitleLabel.font = FootballPalette.caption(12)
        headerTitleLabel.textColor = FootballPalette.textSecondary

        headerDurationLabel.font = FootballPalette.caption(12)
        headerDurationLabel.textColor = FootballPalette.textSecondary
        headerDurationLabel.textAlignment = .right

        eventsStack.axis = .vertical
        eventsStack.spacing = 0

        contentView.addSubview(headerTitleLabel)
        contentView.addSubview(headerDurationLabel)
        contentView.addSubview(eventsStack)

        headerTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.s8)
            make.leading.equalToSuperview().inset(Spacing.s20)
        }
        headerDurationLabel.snp.makeConstraints { make in
            make.centerY.equalTo(headerTitleLabel)
            make.trailing.equalToSuperview().inset(Spacing.s20)
            make.leading.greaterThanOrEqualTo(headerTitleLabel.snp.trailing).offset(Spacing.s8)
        }
        eventsStack.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel.snp.bottom).offset(Spacing.s12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(Spacing.s8)
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
            empty.snp.makeConstraints { $0.height.equalTo(48) }
            return
        }

        for row in section.rows {
            let rowView = MatchTimelineEventRowView()
            rowView.configure(row: row, settings: settings, homeName: homeName, awayName: awayName)
            rowView.applyTheme()
            eventsStack.addArrangedSubview(rowView)
        }
    }
}
