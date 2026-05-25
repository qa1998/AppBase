//
//  FootballSettingsViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import SnapKit
import StoreKit
import UIKit

final class FootballSettingsViewController: FootballScreenViewController<FootballSettingsViewModel> {

    var onManagePlayers: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let squadTitleLabel = UILabel()
    private let managePlayersCard = FootballGlassView()
    private let managePlayersTitleLabel = UILabel()
    private let managePlayersSubtitleLabel = UILabel()
    private let managePlayersChevron = UIImageView()
    private let appearanceTitleLabel = UILabel()
    private let languageRow = FootballSettingsRowView()
    private let themeRowStack = UIStackView()
    private let darkCard = FootballGlassView()
    private let lightCard = FootballGlassView()
    private let darkIconView = UIImageView()
    private let lightIconView = UIImageView()
    private let darkTitleLabel = UILabel()
    private let lightTitleLabel = UILabel()
    private let darkSubtitleLabel = UILabel()
    private let lightSubtitleLabel = UILabel()
    private let generalTitleLabel = UILabel()
    private let privacyRow = FootballSettingsRowView()
    private let policyRow = FootballSettingsRowView()
    private let versionRow = FootballSettingsRowView()
    private let rateRow = FootballSettingsRowView()
    private let clearRow = FootballSettingsRowView()

    override var navSetting: NavigationSetting {
        var setting = super.navSetting
        setting.useLargeTitleView = true
        setting.title = L10n.Football.Settings.title
        return setting
    }

    override func setupUI() {
        super.setupUI()
        refreshLocalization()
        configureGeneralRows()

        contentStack.axis = .vertical
        contentStack.spacing = Spacing.s16

        squadTitleLabel.font = FootballPalette.title(16)
        squadTitleLabel.textColor = FootballPalette.textPrimary

        managePlayersTitleLabel.font = FootballPalette.title(15)
        managePlayersTitleLabel.textColor = FootballPalette.textPrimary
        managePlayersSubtitleLabel.font = FootballPalette.caption()
        managePlayersSubtitleLabel.textColor = FootballPalette.textSecondary
        managePlayersSubtitleLabel.numberOfLines = 2
        managePlayersChevron.image = UIImage(systemName: "chevron.right")
        managePlayersChevron.tintColor = FootballPalette.textSecondary
        managePlayersChevron.contentMode = .scaleAspectFit

        let playersStack = UIStackView(arrangedSubviews: [managePlayersTitleLabel, managePlayersSubtitleLabel])
        playersStack.axis = .vertical
        playersStack.spacing = Spacing.s4
        playersStack.alignment = .leading
        managePlayersCard.addSubview(playersStack)
        managePlayersCard.addSubview(managePlayersChevron)
        playersStack.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(Spacing.s12)
            make.trailing.lessThanOrEqualTo(managePlayersChevron.snp.leading).offset(-Spacing.s8)
        }
        managePlayersChevron.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview().inset(Spacing.s12)
            make.size.equalTo(18)
        }
        let playersTap = UITapGestureRecognizer(target: self, action: #selector(didTapManagePlayers))
        managePlayersCard.addGestureRecognizer(playersTap)
        managePlayersCard.isUserInteractionEnabled = true

        appearanceTitleLabel.font = FootballPalette.title(16)
        appearanceTitleLabel.textColor = FootballPalette.textPrimary
        generalTitleLabel.font = FootballPalette.title(16)
        generalTitleLabel.textColor = FootballPalette.textPrimary

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
        contentStack.addArrangedSubview(squadTitleLabel)
        contentStack.addArrangedSubview(managePlayersCard)
        contentStack.addArrangedSubview(appearanceTitleLabel)
        contentStack.addArrangedSubview(languageRow)
        contentStack.addArrangedSubview(themeRowStack)
        contentStack.addArrangedSubview(generalTitleLabel)
        contentStack.addArrangedSubview(privacyRow)
        contentStack.addArrangedSubview(policyRow)
        contentStack.addArrangedSubview(versionRow)
        contentStack.addArrangedSubview(rateRow)
        contentStack.addArrangedSubview(clearRow)
        managePlayersCard.snp.makeConstraints { $0.height.greaterThanOrEqualTo(64) }

        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.s20)
            make.width.equalTo(scrollView).offset(-Spacing.s40)
        }
        themeRowStack.snp.makeConstraints { $0.height.equalTo(120) }
    }

    private func configureGeneralRows() {
        languageRow.onTap = { [weak self] in self?.presentLanguagePicker() }

        privacyRow.onTap = { [weak self] in self?.openURL(FootballLegalLinks.privacyPolicy) }
        policyRow.onTap = { [weak self] in self?.openURL(FootballLegalLinks.policy) }
        rateRow.onTap = { [weak self] in self?.rateApp() }
        clearRow.onTap = { [weak self] in self?.confirmClearData() }

        versionRow.showsChevron = false
        versionRow.isUserInteractionEnabled = false
        clearRow.usesDestructiveStyle = true
    }

    override func refreshLocalization() {
        super.refreshLocalization()
        squadTitleLabel.text = L10n.Football.Settings.squadSection
        managePlayersTitleLabel.text = L10n.Football.Settings.managePlayers
        managePlayersSubtitleLabel.text = L10n.Football.Settings.managePlayersHint
        appearanceTitleLabel.text = L10n.Football.Settings.appearance
        generalTitleLabel.text = L10n.Football.Settings.generalSection
        darkTitleLabel.text = L10n.Football.Settings.Theme.dark
        lightTitleLabel.text = L10n.Football.Settings.Theme.light
        darkSubtitleLabel.text = L10n.Football.Settings.Theme.darkHint
        lightSubtitleLabel.text = L10n.Football.Settings.Theme.lightHint
        updateLanguageRow()

        privacyRow.configure(title: L10n.Football.Settings.privacy)
        policyRow.configure(title: L10n.Football.Settings.policy)
        versionRow.configure(
            title: L10n.Football.Settings.appVersion,
            value: viewModel.appVersionText
        )
        rateRow.configure(title: L10n.Football.Settings.rateUs)
        clearRow.configure(title: L10n.Football.Settings.clearData)
    }

    override func onBind() {
        super.onBind()
        viewModel.$themeMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshFootballTheme()
            }
            .store(in: &cancelBag)
        viewModel.$currentLanguage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshLocalization()
                self?.refreshNavigationLocalization()
            }
            .store(in: &cancelBag)
    }

    private func updateLanguageRow() {
        languageRow.configure(
            title: L10n.Football.Settings.language,
            value: LocalizationService.shared.currentLanguage.localizedTitle
        )
    }

    override func refreshFootballTheme() {
        super.refreshFootballTheme()
        squadTitleLabel.textColor = FootballPalette.textPrimary
        managePlayersTitleLabel.textColor = FootballPalette.textPrimary
        managePlayersSubtitleLabel.textColor = FootballPalette.textSecondary
        managePlayersChevron.tintColor = FootballPalette.textSecondary
        appearanceTitleLabel.textColor = FootballPalette.textPrimary
        generalTitleLabel.textColor = FootballPalette.textPrimary
        [darkTitleLabel, lightTitleLabel].forEach { $0.textColor = FootballPalette.textPrimary }
        [darkSubtitleLabel, lightSubtitleLabel].forEach { $0.textColor = FootballPalette.textSecondary }
        darkIconView.tintColor = FootballPalette.accentGreen
        lightIconView.tintColor = FootballPalette.accentGreen
        languageRow.applyTheme()
        [privacyRow, policyRow, versionRow, rateRow, clearRow].forEach { $0.applyTheme() }
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

    private func openURL(_ url: URL) {
        guard UIApplication.shared.canOpenURL(url) else {
            viewModel.presentError(message: L10n.Football.Settings.linkUnavailable)
            return
        }
        UIApplication.shared.open(url)
    }

    private func rateApp() {
        if let scene = view.window?.windowScene {
            SKStoreReviewController.requestReview(in: scene)
            return
        }
        if let url = FootballLegalLinks.appStoreReview {
            UIApplication.shared.open(url)
            return
        }
        viewModel.presentError(message: L10n.Football.Settings.linkUnavailable)
    }

    private func presentLanguagePicker() {
        let sheet = UIAlertController(
            title: L10n.Football.Settings.language,
            message: nil,
            preferredStyle: .actionSheet
        )
        let selected = viewModel.currentLanguage
        Language.allCases.forEach { language in
            let mark = language == selected ? "✓ " : ""
            sheet.addAction(UIAlertAction(
                title: mark + language.localizedTitle,
                style: .default
            ) { [weak self] _ in
                self?.viewModel.selectLanguage(language)
            })
        }
        sheet.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = languageRow
            popover.sourceRect = languageRow.bounds
        }
        present(sheet, animated: true)
    }

    private func confirmClearData() {
        let sheet = UIAlertController(
            title: L10n.Football.Settings.clearDataTitle,
            message: L10n.Football.Settings.clearDataMessage,
            preferredStyle: .alert
        )
        sheet.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        sheet.addAction(UIAlertAction(title: L10n.Football.Settings.clearDataConfirm, style: .destructive) { [weak self] _ in
            self?.viewModel.clearFootballData()
        })
        present(sheet, animated: true)
    }

    @objc private func didTapManagePlayers() {
        onManagePlayers?()
    }

    @objc private func didTapDark() {
        viewModel.selectDarkMode()
    }

    @objc private func didTapLight() {
        viewModel.selectLightMode()
    }
}
