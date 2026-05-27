//
//  MatchLiveMinHeaderView.swift
//  AppBase
//

import SnapKit
import UIKit

/// Header gọn: logo/initials hai đội + tỉ số (navigation bar hoặc overlay).
final class MatchLiveMinHeaderView: UIView {

    enum Placement {
        case navigationBar
        case overlay
    }

    var placement: Placement = .overlay {
        didSet { applyPlacement() }
    }

    private let homeBadge = MatchLiveMinTeamBadgeView()
    private let awayBadge = MatchLiveMinTeamBadgeView()
    private let scoreLabel = UILabel()
    private var heightConstraint: Constraint?
    private var homeLeadingConstraint: Constraint?
    private var awayTrailingConstraint: Constraint?
    private var homeSizeConstraint: Constraint?
    private var awaySizeConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
        applyPlacement()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(homeName: String, awayName: String, scoreText: String) {
        homeBadge.configure(name: homeName)
        awayBadge.configure(name: awayName)
        scoreLabel.text = scoreText.replacingOccurrences(of: " - ", with: " – ")
    }

    func applyTheme() {
        switch placement {
        case .navigationBar:
            backgroundColor = .clear
        case .overlay:
            backgroundColor = FootballPalette.background
        }
        scoreLabel.textColor = FootballPalette.textPrimary
        homeBadge.applyTheme()
        awayBadge.applyTheme()
    }

    private func applyPlacement() {
        let badgeSize: CGFloat = placement == .navigationBar ? 28 : 32
        let horizontalInset: CGFloat = placement == .navigationBar ? 0 : Spacing.s16
        let height: CGFloat = placement == .navigationBar ? 36 : 44

        heightConstraint?.update(offset: height)
        homeLeadingConstraint?.update(inset: horizontalInset)
        awayTrailingConstraint?.update(inset: horizontalInset)
        homeSizeConstraint?.update(offset: badgeSize)
        awaySizeConstraint?.update(offset: badgeSize)

        scoreLabel.font = placement == .navigationBar
            ? FootballPalette.title(16)
            : FootballPalette.title(17)

        applyTheme()
    }

    private func build() {
        scoreLabel.font = FootballPalette.title(17)
        scoreLabel.textAlignment = .center
        scoreLabel.adjustsFontSizeToFitWidth = true
        scoreLabel.minimumScaleFactor = 0.8

        addSubview(homeBadge)
        addSubview(scoreLabel)
        addSubview(awayBadge)

        homeBadge.snp.makeConstraints { make in
            homeLeadingConstraint = make.leading.equalToSuperview().inset(Spacing.s16).constraint
            make.centerY.equalToSuperview()
            homeSizeConstraint = make.size.equalTo(32).constraint
        }
        awayBadge.snp.makeConstraints { make in
            awayTrailingConstraint = make.trailing.equalToSuperview().inset(Spacing.s16).constraint
            make.centerY.equalToSuperview()
            awaySizeConstraint = make.size.equalTo(32).constraint
        }
        scoreLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualTo(homeBadge.snp.trailing).offset(Spacing.s8)
            make.trailing.lessThanOrEqualTo(awayBadge.snp.leading).offset(-Spacing.s8)
        }

        snp.makeConstraints { make in
            heightConstraint = make.height.equalTo(44).constraint
        }
    }
}

// MARK: - Badge

private final class MatchLiveMinTeamBadgeView: UIView {

    private let circle = UIView()
    private let initialsLabel = UILabel()

    override func layoutSubviews() {
        super.layoutSubviews()
        circle.layer.cornerRadius = bounds.width / 2
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        circle.layer.borderWidth = 1
        initialsLabel.font = FootballPalette.title(11)
        initialsLabel.textAlignment = .center
        addSubview(circle)
        circle.addSubview(initialsLabel)
        circle.snp.makeConstraints { $0.edges.equalToSuperview() }
        initialsLabel.snp.makeConstraints { $0.center.equalToSuperview() }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(name: String) {
        let parts = name.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map { String($0) }
        initialsLabel.text = letters.joined().uppercased().isEmpty ? "?" : letters.joined().uppercased()
    }

    func applyTheme() {
        circle.backgroundColor = FootballPalette.surfaceElevated
        circle.layer.borderColor = FootballPalette.glassBorder.cgColor
        initialsLabel.textColor = FootballPalette.textPrimary
    }
}
