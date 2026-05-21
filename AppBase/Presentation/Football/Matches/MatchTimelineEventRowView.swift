//
//  MatchTimelineEventRowView.swift
//  AppBase
//

import SnapKit
import UIKit

/// Một dòng sự kiện trên timeline (phút · trục · icon · tên · tỷ số).
final class MatchTimelineEventRowView: UIView {

    private let minuteLabel = UILabel()
    private let topLine = UIView()
    private let bottomLine = UIView()
    private let dotView = UIView()
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let cardIconView = UIView()
    private let nameLabel = UILabel()
    private let detailLabel = UILabel()
    private let scoreBadge = UILabel()

    private let trackX: CGFloat = 52

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        minuteLabel.font = FootballPalette.caption(13)
        minuteLabel.textColor = FootballPalette.textSecondary
        minuteLabel.textAlignment = .right

        topLine.backgroundColor = FootballPalette.textSecondary.withAlphaComponent(0.35)
        bottomLine.backgroundColor = topLine.backgroundColor
        dotView.backgroundColor = FootballPalette.textSecondary.withAlphaComponent(0.55)
        dotView.layer.cornerRadius = 4

        iconImageView.contentMode = .scaleAspectFit
        cardIconView.layer.cornerRadius = 3
        cardIconView.isHidden = true

        nameLabel.font = FootballPalette.title(15)
        nameLabel.textColor = FootballPalette.textPrimary

        detailLabel.font = FootballPalette.caption(12)
        detailLabel.textColor = FootballPalette.textSecondary
        detailLabel.isHidden = true

        scoreBadge.font = FootballPalette.caption(12)
        scoreBadge.textColor = FootballPalette.textPrimary
        scoreBadge.textAlignment = .center
        scoreBadge.backgroundColor = FootballPalette.surfaceElevated
        scoreBadge.layer.cornerRadius = Radius.s8
        scoreBadge.clipsToBounds = true
        scoreBadge.isHidden = true

        addSubview(topLine)
        addSubview(bottomLine)
        addSubview(dotView)
        addSubview(minuteLabel)
        addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        iconContainer.addSubview(cardIconView)
        addSubview(nameLabel)
        addSubview(detailLabel)
        addSubview(scoreBadge)

        minuteLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.s16)
            make.width.equalTo(32)
            make.centerY.equalTo(dotView)
        }
        dotView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(trackX)
            make.centerY.equalToSuperview()
            make.size.equalTo(8)
        }
        topLine.snp.makeConstraints { make in
            make.width.equalTo(2)
            make.centerX.equalTo(dotView)
            make.top.equalToSuperview()
            make.bottom.equalTo(dotView.snp.centerY)
        }
        bottomLine.snp.makeConstraints { make in
            make.width.equalTo(2)
            make.centerX.equalTo(dotView)
            make.top.equalTo(dotView.snp.centerY)
            make.bottom.equalToSuperview()
        }
        iconContainer.snp.makeConstraints { make in
            make.leading.equalTo(dotView.snp.trailing).offset(Spacing.s12)
            make.centerY.equalToSuperview()
            make.size.equalTo(28)
        }
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(22)
        }
        cardIconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(12)
            make.height.equalTo(16)
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(Spacing.s10)
            make.top.equalToSuperview().offset(Spacing.s12)
            make.trailing.lessThanOrEqualTo(scoreBadge.snp.leading).offset(-Spacing.s8)
        }
        detailLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.trailing.equalTo(nameLabel)
            make.bottom.equalToSuperview().inset(Spacing.s12)
        }
        scoreBadge.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Spacing.s16)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(52)
            make.height.equalTo(28)
        }

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(52)
        }
    }

    func configure(
        row: MatchTimelineEventRow,
        settings: FootballMatchSettings,
        homeName: String,
        awayName: String
    ) {
        let event = row.event
        minuteLabel.text = minuteText(event, settings: settings)
        topLine.isHidden = row.isFirstInSection
        bottomLine.isHidden = row.isLastInSection

        applyIcon(for: event.type)
        nameLabel.text = displayName(for: event)

        let showsDetail: Bool
        switch event.type {
        case .substitution, .varReview, .penalty:
            showsDetail = true
            detailLabel.text = eventSubtitle(event.type)
        default:
            showsDetail = false
        }
        detailLabel.isHidden = !showsDetail
        if showsDetail {
            nameLabel.snp.remakeConstraints { make in
                make.leading.equalTo(iconContainer.snp.trailing).offset(Spacing.s10)
                make.top.equalToSuperview().offset(Spacing.s12)
                make.trailing.lessThanOrEqualTo(scoreBadge.snp.leading).offset(-Spacing.s8)
            }
        } else {
            nameLabel.snp.remakeConstraints { make in
                make.leading.equalTo(iconContainer.snp.trailing).offset(Spacing.s10)
                make.centerY.equalToSuperview()
                make.trailing.lessThanOrEqualTo(scoreBadge.snp.leading).offset(-Spacing.s8)
            }
        }

        if let score = row.scoreText {
            scoreBadge.isHidden = false
            scoreBadge.text = "  \(score)  "
        } else {
            scoreBadge.isHidden = true
        }
    }

    private func minuteText(_ event: MatchEvent, settings: FootballMatchSettings) -> String {
        let display = event.timelineMinute(settings: settings)
        if let stoppage = display.stoppage {
            return "\(display.minute)+\(stoppage)'"
        }
        return "\(display.minute)'"
    }

    private func displayName(for event: MatchEvent) -> String {
        if event.type == .varReview, event.team == .neutral {
            return L10n.Football.Match.Event.varReview
        }
        return event.playerName
    }

    private func eventSubtitle(_ type: MatchEventType) -> String {
        switch type {
        case .substitution: return L10n.Football.Match.Event.substitution
        case .varReview: return L10n.Football.Match.Event.varReview
        case .penalty: return L10n.Football.Match.Event.penalty
        default: return ""
        }
    }

    private func applyIcon(for type: MatchEventType) {
        cardIconView.isHidden = true
        iconImageView.isHidden = false
        iconContainer.backgroundColor = .clear
        iconContainer.layer.cornerRadius = 0

        switch type {
        case .goal:
            iconContainer.backgroundColor = FootballPalette.accentGreen.withAlphaComponent(0.2)
            iconContainer.layer.cornerRadius = 14
            iconImageView.image = UIImage(systemName: "soccerball")
            iconImageView.tintColor = FootballPalette.accentGreen
        case .yellowCard:
            iconImageView.isHidden = true
            cardIconView.isHidden = false
            cardIconView.backgroundColor = UIColor(hex: 0xFACC15)
        case .redCard:
            iconImageView.isHidden = true
            cardIconView.isHidden = false
            cardIconView.backgroundColor = FootballPalette.accentRed
        case .substitution:
            iconImageView.image = UIImage(systemName: "arrow.left.arrow.right")
            iconImageView.tintColor = FootballPalette.textPrimary
        case .varReview:
            iconImageView.image = UIImage(systemName: "tv")
            iconImageView.tintColor = FootballPalette.textSecondary
        case .penalty:
            iconImageView.image = UIImage(systemName: "flag.fill")
            iconImageView.tintColor = FootballPalette.accentGreen
        }
    }
}
