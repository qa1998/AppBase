//
//  MatchTimelineEventRowView.swift
//  AppBase
//

import SnapKit
import UIKit

/// Một sự kiện trên timeline — trục giữa, nội dung trái (nhà) / phải (khách).
final class MatchTimelineEventRowView: UIView {

    private let spineTop = UIView()
    private let spineBottom = UIView()
    private let minuteNode = UIView()
    private let minuteLabel = UILabel()
    private let contentPanel = UIView()
    private let iconView = UIImageView()
    private let cardIconView = UIView()
    private let cardBadgeStack = UIStackView()
    private let nameLabel = UILabel()
    private let detailLabel = UILabel()
    private let scoreBadge = UILabel()

    private var contentLeadingConstraint: Constraint?
    private var contentTrailingConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        row: MatchTimelineEventRow,
        settings: FootballMatchSettings,
        homeName: String,
        awayName: String
    ) {
        let event = row.event
        let displayType = row.displayType
        minuteLabel.text = minuteText(event, settings: settings)
        spineTop.isHidden = row.isFirstInSection
        spineBottom.isHidden = row.isLastInSection

        applyMinuteAccent(for: displayType, row: row)
        applyIcon(for: row)
        nameLabel.text = displayName(for: event)

        let showsDetail: Bool
        switch event.type {
        case .substitution, .varReview, .penalty, .yellowCard, .redCard:
            showsDetail = true
            detailLabel.text = cardDetailText(row: row)
        default:
            showsDetail = false
        }
        detailLabel.isHidden = !showsDetail
        if showsDetail {
            detailLabel.snp.remakeConstraints { make in
                make.leading.equalTo(nameLabel)
                make.top.equalTo(nameLabel.snp.bottom).offset(2)
                make.trailing.equalTo(nameLabel)
                make.bottom.equalToSuperview()
            }
        } else {
            detailLabel.snp.remakeConstraints { make in
                make.leading.trailing.equalTo(nameLabel)
                make.top.equalTo(nameLabel.snp.bottom)
                make.height.equalTo(0)
            }
        }

        if let score = row.scoreText {
            scoreBadge.isHidden = false
            scoreBadge.text = "  \(score)  "
        } else {
            scoreBadge.isHidden = true
        }

        layoutContent(for: event.team)
    }

    func applyTheme() {
        let spine = FootballPalette.textSecondary.withAlphaComponent(0.28)
        spineTop.backgroundColor = spine
        spineBottom.backgroundColor = spine
        minuteNode.backgroundColor = FootballPalette.surfaceElevated
        minuteLabel.textColor = FootballPalette.textPrimary
        nameLabel.textColor = FootballPalette.textPrimary
        detailLabel.textColor = FootballPalette.textSecondary
        scoreBadge.textColor = FootballPalette.accentGreen
        scoreBadge.layer.borderColor = FootballPalette.accentGreen.withAlphaComponent(0.55).cgColor
        scoreBadge.backgroundColor = FootballPalette.surface
    }

    private func setup() {
        let spineColor = FootballPalette.textSecondary.withAlphaComponent(0.28)
        spineTop.backgroundColor = spineColor
        spineBottom.backgroundColor = spineColor

        minuteNode.backgroundColor = FootballPalette.surfaceElevated
        minuteNode.layer.cornerRadius = 18
        minuteNode.layer.borderWidth = 2
        minuteNode.layer.borderColor = FootballPalette.glassBorder.cgColor

        minuteLabel.font = FootballPalette.caption(12)
        minuteLabel.textColor = FootballPalette.textPrimary
        minuteLabel.textAlignment = .center

        iconView.contentMode = .scaleAspectFit
        cardIconView.layer.cornerRadius = 3
        cardIconView.isHidden = true

        nameLabel.font = FootballPalette.title(15)
        nameLabel.textColor = FootballPalette.textPrimary

        detailLabel.font = FootballPalette.caption(12)
        detailLabel.textColor = FootballPalette.textSecondary
        detailLabel.numberOfLines = 2

        scoreBadge.font = FootballPalette.caption(12)
        scoreBadge.textColor = FootballPalette.accentGreen
        scoreBadge.textAlignment = .center
        scoreBadge.backgroundColor = FootballPalette.surface
        scoreBadge.layer.cornerRadius = Radius.s8
        scoreBadge.layer.borderWidth = 1
        scoreBadge.layer.borderColor = FootballPalette.accentGreen.withAlphaComponent(0.55).cgColor
        scoreBadge.clipsToBounds = true
        scoreBadge.isHidden = true

        addSubview(spineTop)
        addSubview(spineBottom)
        addSubview(minuteNode)
        minuteNode.addSubview(minuteLabel)
        addSubview(contentPanel)
        cardBadgeStack.axis = .horizontal
        cardBadgeStack.spacing = 3
        cardBadgeStack.alignment = .center
        cardBadgeStack.isHidden = true

        contentPanel.addSubview(iconView)
        contentPanel.addSubview(cardIconView)
        contentPanel.addSubview(cardBadgeStack)
        contentPanel.addSubview(nameLabel)
        contentPanel.addSubview(detailLabel)
        contentPanel.addSubview(scoreBadge)

        minuteLabel.snp.makeConstraints { $0.center.equalToSuperview() }

        spineTop.snp.makeConstraints { make in
            make.width.equalTo(2)
            make.centerX.equalTo(minuteNode)
            make.top.equalToSuperview()
            make.bottom.equalTo(minuteNode.snp.top)
        }
        spineBottom.snp.makeConstraints { make in
            make.width.equalTo(2)
            make.centerX.equalTo(minuteNode)
            make.top.equalTo(minuteNode.snp.bottom)
            make.bottom.equalToSuperview()
        }

        contentPanel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.42)
            contentLeadingConstraint = make.leading.equalToSuperview().inset(Spacing.s16).constraint
            contentTrailingConstraint = make.trailing.equalTo(minuteNode.snp.leading).offset(-Spacing.s12).constraint
        }

        minuteNode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(contentPanel)
            make.size.equalTo(36)
        }

        iconView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.size.equalTo(22)
        }
        cardIconView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.width.equalTo(12)
            make.height.equalTo(16)
        }
        cardBadgeStack.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.height.equalTo(16)
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(Spacing.s8)
            make.top.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
        detailLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.trailing.equalTo(nameLabel)
            make.bottom.equalToSuperview()
        }
        scoreBadge.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(Spacing.s8)
            make.centerY.equalTo(nameLabel)
            make.trailing.lessThanOrEqualToSuperview()
            make.height.equalTo(26)
        }

        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(56).priority(.high)
        }
    }

    private func layoutContent(for team: MatchTeamSide) {
        contentLeadingConstraint?.deactivate()
        contentTrailingConstraint?.deactivate()

        switch team {
        case .home:
            contentPanel.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.bottom.equalToSuperview().offset(-10)
                make.trailing.equalTo(minuteNode.snp.leading).offset(-Spacing.s12)
                make.leading.greaterThanOrEqualToSuperview().offset(Spacing.s16)
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.44)
            }
            nameLabel.textAlignment = .right
            detailLabel.textAlignment = .right
            contentPanel.semanticContentAttribute = .forceRightToLeft
        case .away:
            contentPanel.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.bottom.equalToSuperview().offset(-10)
                make.leading.equalTo(minuteNode.snp.trailing).offset(Spacing.s12)
                make.trailing.lessThanOrEqualToSuperview().inset(Spacing.s16)
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.44)
            }
            nameLabel.textAlignment = .left
            detailLabel.textAlignment = .left
            contentPanel.semanticContentAttribute = .forceLeftToRight
        case .neutral:
            contentPanel.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.bottom.equalToSuperview().offset(-10)
                make.centerX.equalToSuperview()
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.72)
            }
            nameLabel.textAlignment = .center
            detailLabel.textAlignment = .center
            contentPanel.semanticContentAttribute = .forceLeftToRight
        }
    }

    private func applyMinuteAccent(for type: MatchEventType, row: MatchTimelineEventRow) {
        if row.event.type == .yellowCard, row.yellowCardIndex == 2, row.displayType == .redCard {
            minuteNode.layer.borderColor = FootballPalette.accentRed.cgColor
            return
        }
        switch type {
        case .yellowCard:
            minuteNode.layer.borderColor = UIColor(hex: 0xFACC15).cgColor
        case .redCard:
            minuteNode.layer.borderColor = FootballPalette.accentRed.cgColor
        default:
            minuteNode.layer.borderColor = FootballPalette.glassBorder.cgColor
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

    private func cardDetailText(row: MatchTimelineEventRow) -> String {
        let event = row.event
        switch event.type {
        case .yellowCard:
            if row.displayType == .redCard, row.yellowCardIndex == 2 {
                return L10n.Football.Match.Event.twoYellowsRed
            }
            return L10n.Football.Match.Event.yellowCard
        case .redCard:
            return L10n.Football.Match.Event.redCard
        default:
            return eventSubtitle(event.type)
        }
    }

    private func eventSubtitle(_ type: MatchEventType) -> String {
        switch type {
        case .goal: return L10n.Football.Match.Event.goal
        case .yellowCard: return L10n.Football.Match.Event.yellowCard
        case .redCard: return L10n.Football.Match.Event.redCard
        case .substitution: return L10n.Football.Match.Event.substitution
        case .varReview: return L10n.Football.Match.Event.varReview
        case .penalty: return L10n.Football.Match.Event.penalty
        }
    }

    private func applyIcon(for row: MatchTimelineEventRow) {
        cardIconView.isHidden = true
        cardBadgeStack.isHidden = true
        iconView.isHidden = false
        cardBadgeStack.arrangedSubviews.forEach {
            cardBadgeStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        if row.event.type == .yellowCard, row.yellowCardIndex == 2, row.displayType == .redCard {
            iconView.isHidden = true
            cardBadgeStack.isHidden = false
            let yellow = UIColor(hex: 0xFACC15)
            [yellow, yellow, FootballPalette.accentRed].enumerated().forEach { index, color in
                let strip = makeCardStrip(
                    color: color,
                    width: index == 2 ? 10 : 8,
                    height: index == 2 ? 14 : 12
                )
                cardBadgeStack.addArrangedSubview(strip)
            }
            relayoutNameAfterCardBadge()
            return
        }

        relayoutNameAfterIcon()
        applySingleCardIcon(for: row.displayType)
    }

    private func relayoutNameAfterIcon() {
        nameLabel.snp.remakeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(Spacing.s8)
            make.top.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
    }

    private func relayoutNameAfterCardBadge() {
        nameLabel.snp.remakeConstraints { make in
            make.leading.equalTo(cardBadgeStack.snp.trailing).offset(Spacing.s8)
            make.top.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
    }

    private func makeCardStrip(color: UIColor, width: CGFloat, height: CGFloat) -> UIView {
        let strip = UIView()
        strip.backgroundColor = color
        strip.layer.cornerRadius = 2
        strip.snp.makeConstraints { make in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }
        return strip
    }

    private func applySingleCardIcon(for type: MatchEventType) {
        cardIconView.isHidden = true
        iconView.isHidden = false

        switch type {
        case .goal:
            iconView.image = UIImage(systemName: "soccerball")
            iconView.tintColor = FootballPalette.accentGreen
        case .yellowCard:
            iconView.isHidden = true
            cardIconView.isHidden = false
            cardIconView.backgroundColor = UIColor(hex: 0xFACC15)
        case .redCard:
            iconView.isHidden = true
            cardIconView.isHidden = false
            cardIconView.backgroundColor = FootballPalette.accentRed
        case .substitution:
            iconView.image = UIImage(systemName: "arrow.left.arrow.right")
            iconView.tintColor = FootballPalette.textPrimary
        case .varReview:
            iconView.image = UIImage(systemName: "tv")
            iconView.tintColor = FootballPalette.textSecondary
        case .penalty:
            iconView.image = UIImage(systemName: "soccerball")
            iconView.tintColor = FootballPalette.accentGreen
        }
    }
}
