//
//  MatchLiveLineupsView.swift
//  AppBase
//

import SnapKit
import UIKit

/// Tab đội hình — một sân, đội nhà nửa trên / đội khách nửa dưới.
final class MatchLiveLineupsView: UIView {

    /// Sân dọc hơn màn setup (GK mép trên/dưới, tiền đạo hướng về giữa sân).
    /// Thấp hơn = sân cao hơn → đủ chỗ trải 5 hàng / đội.
    static let combinedPitchWidthToHeightRatio: CGFloat = 0.38

    private let content = UIView()
    private let headerCard = UIView()
    private let homeNameLabel = UILabel()
    private let homeFormationLabel = UILabel()
    private let awayNameLabel = UILabel()
    private let awayFormationLabel = UILabel()
    private let pitchCard = UIView()
    private let pitchView = FootballPitchView()

    private var homeTokens: [FootballPlayerTokenView] = []
    private var awayTokens: [FootballPlayerTokenView] = []
    private var homeFormation: FootballFormation = .default
    private var awayFormation: FootballFormation = .default

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        settings: FootballMatchSettings,
        playerStatus: @escaping (String, MatchTeamSide) -> MatchLivePlayerStatus
    ) {
        homeFormation = FootballFormation.catalog.first { $0.id == settings.homeRoster.formationId }
            ?? .default
        awayFormation = FootballFormation.catalog.first { $0.id == settings.awayRoster.formationId }
            ?? .default

        homeNameLabel.text = settings.homeTeam
        homeFormationLabel.text = homeFormation.name
        awayNameLabel.text = settings.awayTeam
        awayFormationLabel.text = awayFormation.name

        clearTokens()
        homeTokens = makeTokens(
            roster: settings.homeRoster,
            team: .home,
            playerStatus: playerStatus
        )
        awayTokens = makeTokens(
            roster: settings.awayRoster,
            team: .away,
            playerStatus: playerStatus
        )
        (homeTokens + awayTokens).forEach { pitchView.addSubview($0) }
        setNeedsLayout()
        relayoutPitchTokens()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pitchView.layoutIfNeeded()
        relayoutPitchTokens()
    }

    /// Đặt lại vị trí token sau khi sân có kích thước thật (tránh dồn góc khi width tạm = 1).
    func relayoutPitchTokens() {
        guard pitchView.bounds.width > 48, pitchView.bounds.height > 48 else { return }
        layoutTokensOnPitch()
    }

    /// Chiều cao nội dung khi nhúng trong scroll cha.
    func preferredHeight(forWidth width: CGFloat) -> CGFloat {
        let header: CGFloat = 56
        let pitchInsets: CGFloat = Spacing.s12 * 2
        let pitchH = max(0, (width - pitchInsets) / Self.combinedPitchWidthToHeightRatio)
        return header + Spacing.s10 + pitchH + pitchInsets
    }

    func applyTheme() {
        headerCard.backgroundColor = FootballPalette.surface
        pitchCard.backgroundColor = FootballPalette.surface
        homeNameLabel.textColor = FootballPalette.textPrimary
        awayNameLabel.textColor = FootballPalette.textPrimary
        homeFormationLabel.textColor = FootballPalette.textSecondary
        awayFormationLabel.textColor = FootballPalette.textSecondary
        pitchView.setNeedsDisplay()
        (homeTokens + awayTokens).forEach { $0.configure(player: $0.player) }
    }

    private func build() {
        backgroundColor = .clear

        var options = PitchDisplayOptions.default
        options.surfaceStyle = .full
        pitchView.displayOptions = options

        homeNameLabel.font = FootballPalette.title(15)
        awayNameLabel.font = FootballPalette.title(15)
        homeNameLabel.textAlignment = .left
        awayNameLabel.textAlignment = .right
        homeFormationLabel.font = FootballPalette.caption(12)
        awayFormationLabel.font = FootballPalette.caption(12)
        homeFormationLabel.textAlignment = .left
        awayFormationLabel.textAlignment = .right

        headerCard.layer.cornerRadius = Radius.s12
        headerCard.addSubview(homeNameLabel)
        headerCard.addSubview(homeFormationLabel)
        headerCard.addSubview(awayNameLabel)
        headerCard.addSubview(awayFormationLabel)

        pitchCard.layer.cornerRadius = Radius.s16
        pitchCard.addSubview(pitchView)

        content.addSubview(headerCard)
        content.addSubview(pitchCard)
        addSubview(content)

        content.snp.makeConstraints { $0.edges.equalToSuperview() }
        headerCard.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        homeNameLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.s12)
            make.trailing.lessThanOrEqualTo(headerCard.snp.centerX).offset(-Spacing.s8)
        }
        homeFormationLabel.snp.makeConstraints { make in
            make.top.equalTo(homeNameLabel.snp.bottom).offset(2)
            make.leading.equalTo(homeNameLabel)
            make.bottom.equalToSuperview().inset(Spacing.s12)
        }
        awayNameLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(Spacing.s12)
            make.leading.greaterThanOrEqualTo(headerCard.snp.centerX).offset(Spacing.s8)
        }
        awayFormationLabel.snp.makeConstraints { make in
            make.top.equalTo(awayNameLabel.snp.bottom).offset(2)
            make.trailing.equalTo(awayNameLabel)
            make.bottom.equalToSuperview().inset(Spacing.s12)
        }
        pitchCard.snp.makeConstraints { make in
            make.top.equalTo(headerCard.snp.bottom).offset(Spacing.s10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        pitchView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.s12)
            make.height.equalTo(pitchView.snp.width).dividedBy(MatchLiveLineupsView.combinedPitchWidthToHeightRatio)
        }
    }

    private func clearTokens() {
        (homeTokens + awayTokens).forEach { $0.removeFromSuperview() }
        homeTokens.removeAll()
        awayTokens.removeAll()
    }

    private func makeTokens(
        roster: MatchTeamRoster,
        team: MatchTeamSide,
        playerStatus: (String, MatchTeamSide) -> MatchLivePlayerStatus
    ) -> [FootballPlayerTokenView] {
        roster.assignments.compactMap { assignment -> FootballPlayerTokenView? in
            guard let player = assignment.player else { return nil }
            let token = FootballPlayerTokenView(
                slotIndex: assignment.slotIndex,
                player: player,
                size: .pitch
            )
            token.allowsDrag = false
            token.isUserInteractionEnabled = false
            MatchLiveLineupTokenDecoration.apply(to: token, status: playerStatus(player.id, team))
            return token
        }
    }

    private func layoutTokensOnPitch() {
        PitchPlayerTokenLayout.layoutCombined(
            homeTokens: homeTokens,
            homeFormation: homeFormation,
            awayTokens: awayTokens,
            awayFormation: awayFormation,
            in: pitchView
        )
    }
}

// MARK: - Token badges

private enum MatchLiveLineupTokenDecoration {

    static func apply(to token: FootballPlayerTokenView, status: MatchLivePlayerStatus) {
        token.alpha = status.isSentOff ? 0.38 : 1
        let circleTop: CGFloat = 0
        let circleSize: CGFloat = 38

        if status.isSentOff {
            addCardStrip(on: token, color: FootballPalette.accentRed, width: 10, circleTop: circleTop, circleSize: circleSize)
        } else if status.yellowCount > 0 {
            addCardStrip(on: token, color: UIColor(hex: 0xFACC15), width: 8, circleTop: circleTop, circleSize: circleSize)
        }

        if status.goalCount > 0 {
            let icon = UIImageView(image: UIImage(systemName: "soccerball"))
            icon.tintColor = FootballPalette.accentGreen
            icon.contentMode = .scaleAspectFit
            token.addSubview(icon)
            icon.snp.makeConstraints { make in
                make.size.equalTo(14)
                make.trailing.equalToSuperview()
                make.top.equalToSuperview().offset(circleTop + circleSize - 10)
            }
        }

        if let minute = status.substitutionMinute {
            let pill = PaddingLabel()
            pill.textInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
            pill.font = FootballPalette.caption(9)
            pill.textColor = FootballPalette.onAccent
            pill.backgroundColor = FootballPalette.accentRed
            pill.layer.cornerRadius = 8
            pill.clipsToBounds = true
            pill.text = "\(minute)'"
            token.addSubview(pill)
            pill.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(-4)
            }
        }
    }

    private static func addCardStrip(
        on token: UIView,
        color: UIColor,
        width: CGFloat,
        circleTop: CGFloat,
        circleSize: CGFloat
    ) {
        let strip = UIView()
        strip.backgroundColor = color
        strip.layer.cornerRadius = 2
        token.addSubview(strip)
        strip.snp.makeConstraints { make in
            make.width.equalTo(width)
            make.height.equalTo(14)
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(circleTop + (circleSize - 14) / 2)
        }
    }
}
