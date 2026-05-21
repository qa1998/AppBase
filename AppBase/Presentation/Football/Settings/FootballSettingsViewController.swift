//
//  FootballSettingsViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import SnapKit
import UIKit

final class FootballSettingsViewController: FootballScreenViewController<FootballSettingsViewModel> {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let appearanceTitleLabel = UILabel()
    private let themeRowStack = UIStackView()
    private let darkCard = FootballGlassView()
    private let lightCard = FootballGlassView()
    private let darkIconView = UIImageView()
    private let lightIconView = UIImageView()
    private let darkTitleLabel = UILabel()
    private let lightTitleLabel = UILabel()
    private let darkSubtitleLabel = UILabel()
    private let lightSubtitleLabel = UILabel()

    override func setupUI() {
        super.setupUI()
        refreshLocalization()

        contentStack.axis = .vertical
        contentStack.spacing = Spacing.s16

        appearanceTitleLabel.font = FootballPalette.title(16)
        appearanceTitleLabel.textColor = FootballPalette.textPrimary

        themeRowStack.axis = .horizontal
        themeRowStack.spacing = Spacing.s12
        themeRowStack.distribution = .fillEqually

        [darkIconView, lightIconView].forEach {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = FootballPalette.accentGreen
        }
        darkIconView.image = UIImage(systemName: "moon.fill")
        lightIconView.image = UIImage(systemName: "sun.max.fill")

        [darkTitleLabel, lightTitleLabel].forEach {
            $0.font = FootballPalette.title(15)
            $0.textColor = FootballPalette.textPrimary
        }
        [darkSubtitleLabel, lightSubtitleLabel].forEach {
            $0.font = FootballPalette.caption()
            $0.textColor = FootballPalette.textSecondary
            $0.numberOfLines = 2
        }

        layoutThemeCard(
            card: darkCard,
            icon: darkIconView,
            title: darkTitleLabel,
            subtitle: darkSubtitleLabel,
            action: #selector(didTapDark)
        )
        layoutThemeCard(
            card: lightCard,
            icon: lightIconView,
            title: lightTitleLabel,
            subtitle: lightSubtitleLabel,
            action: #selector(didTapLight)
        )

        themeRowStack.addArrangedSubview(darkCard)
        themeRowStack.addArrangedSubview(lightCard)

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(appearanceTitleLabel)
        contentStack.addArrangedSubview(themeRowStack)

        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.s20)
            make.width.equalTo(scrollView).offset(-Spacing.s40)
        }
        themeRowStack.snp.makeConstraints { $0.height.equalTo(120) }
    }

    override func refreshLocalization() {
        title = L10n.Football.Settings.title
        appearanceTitleLabel.text = L10n.Football.Settings.appearance
        darkTitleLabel.text = L10n.Football.Settings.Theme.dark
        lightTitleLabel.text = L10n.Football.Settings.Theme.light
        darkSubtitleLabel.text = L10n.Football.Settings.Theme.darkHint
        lightSubtitleLabel.text = L10n.Football.Settings.Theme.lightHint
    }

    override func onBind() {
        super.onBind()
        viewModel.$themeMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshFootballTheme()
            }
            .store(in: &cancelBag)
    }

    override func refreshFootballTheme() {
        super.refreshFootballTheme()
        appearanceTitleLabel.textColor = FootballPalette.textPrimary
        [darkTitleLabel, lightTitleLabel].forEach { $0.textColor = FootballPalette.textPrimary }
        [darkSubtitleLabel, lightSubtitleLabel].forEach { $0.textColor = FootballPalette.textSecondary }
        darkIconView.tintColor = FootballPalette.accentGreen
        lightIconView.tintColor = FootballPalette.accentGreen
        updateThemeSelection()
    }

    private func layoutThemeCard(
        card: FootballGlassView,
        icon: UIImageView,
        title: UILabel,
        subtitle: UILabel,
        action: Selector
    ) {
        let stack = UIStackView(arrangedSubviews: [icon, title, subtitle])
        stack.axis = .vertical
        stack.spacing = Spacing.s4
        stack.alignment = .leading
        card.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(Spacing.s12) }
        icon.snp.makeConstraints { $0.size.equalTo(28) }
        let tap = UITapGestureRecognizer(target: self, action: action)
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true
    }

    private func updateThemeSelection() {
        darkCard.showsNeonBorder = viewModel.isDarkSelected
        darkCard.neonColor = FootballPalette.accentGreen
        lightCard.showsNeonBorder = viewModel.isLightSelected
        lightCard.neonColor = FootballPalette.accentGreen
    }

    @objc private func didTapDark() {
        viewModel.selectDarkMode()
    }

    @objc private func didTapLight() {
        viewModel.selectLightMode()
    }
}
