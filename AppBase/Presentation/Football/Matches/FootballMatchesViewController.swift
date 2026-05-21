//
//  FootballMatchesViewController.swift
//  AppBase
//

import BaseMVVM
import SnapKit
import UIKit

/// Placeholder for Matches tab (design reference).
final class FootballMatchesViewController: FootballScreenViewController<FootballMatchesViewModel> {

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override func setupUI() {
        super.setupUI()
        navigationController?.setNavigationBarHidden(true, animated: false)

        iconView.image = UIImage(systemName: "soccerball")
        iconView.tintColor = FootballPalette.textSecondary
        iconView.contentMode = .scaleAspectFit

        titleLabel.font = FootballPalette.headline(22)
        titleLabel.textColor = FootballPalette.textPrimary
        titleLabel.textAlignment = .center

        subtitleLabel.font = FootballPalette.body()
        subtitleLabel.textColor = FootballPalette.textSecondary
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        refreshLocalization()

        view.addSubview(iconView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        iconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.size.equalTo(64)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(Spacing.s16)
            make.leading.trailing.equalToSuperview().inset(Spacing.s32)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.s8)
            make.leading.trailing.equalTo(titleLabel)
        }
    }

    override func refreshLocalization() {
        titleLabel.text = L10n.Football.Matches.title
        subtitleLabel.text = L10n.Football.Matches.subtitle
    }
}
