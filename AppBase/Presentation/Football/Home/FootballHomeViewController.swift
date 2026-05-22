//
//  FootballHomeViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import SnapKit
import UIKit

final class FootballHomeViewController: FootballScreenViewController<FootballHomeViewModel> {

    var onCreateLineup: (() -> Void)?
    var onOpenLineup: ((FootballLineup) -> Void)?
    var onOpenEditor: (() -> Void)?
    var onOpenTactics: (() -> Void)?
    var onOpenExport: (() -> Void)?
    var showsCloseButton = false
    var onClose: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let greetingLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let createButton = FootballNeonButton(title: "", style: .primary)
    private let recentTitleLabel = UILabel()
    private let recentStack = UIStackView()
    private let templatesTitleLabel = UILabel()
    private let templatesScroll = UIScrollView()
    private let templatesStack = UIStackView()
    private let shortcutsTitleLabel = UILabel()
    private let shortcutsStack = UIStackView()

    override func setupUI() {
        super.setupUI()
        if showsCloseButton {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(didTapClose)
            )
        }
        refreshLocalization()

        contentStack.axis = .vertical
        contentStack.spacing = Spacing.s20

        greetingLabel.font = FootballPalette.headline(26)
        greetingLabel.textColor = FootballPalette.textPrimary

        subtitleLabel.font = FootballPalette.body()
        subtitleLabel.textColor = FootballPalette.textSecondary
        subtitleLabel.numberOfLines = 0

        recentStack.axis = .vertical
        recentStack.spacing = Spacing.s12

        templatesScroll.showsHorizontalScrollIndicator = false
        templatesStack.axis = .horizontal
        templatesStack.spacing = Spacing.s12
        templatesScroll.addSubview(templatesStack)
        templatesStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        shortcutsStack.axis = .horizontal
        shortcutsStack.spacing = Spacing.s12
        shortcutsStack.distribution = .fillEqually

        [recentTitleLabel, templatesTitleLabel, shortcutsTitleLabel].forEach {
            $0.font = FootballPalette.title(16)
            $0.textColor = FootballPalette.textPrimary
        }

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(greetingLabel)
        contentStack.addArrangedSubview(subtitleLabel)
        contentStack.addArrangedSubview(createButton)
        contentStack.addArrangedSubview(recentTitleLabel)
        contentStack.addArrangedSubview(recentStack)
        contentStack.addArrangedSubview(templatesTitleLabel)
        contentStack.addArrangedSubview(templatesScroll)
        contentStack.addArrangedSubview(shortcutsTitleLabel)
        contentStack.addArrangedSubview(shortcutsStack)

        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.s20)
            make.width.equalTo(scrollView).offset(-Spacing.s40)
        }
        templatesScroll.snp.makeConstraints { $0.height.equalTo(120) }

        createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        buildTemplates()
        buildShortcuts()
    }

    override func refreshLocalization() {
        title = L10n.Football.Tab.lineups
        greetingLabel.text = L10n.Football.Home.greeting
        subtitleLabel.text = L10n.Football.Home.subtitle
        createButton.setTitle(L10n.Football.Home.create, for: .normal)
        recentTitleLabel.text = L10n.Football.Home.recent
        templatesTitleLabel.text = L10n.Football.Home.templates
        shortcutsTitleLabel.text = L10n.Football.Home.shortcuts
    }

    override func onBind() {
        super.onBind()
        viewModel.$recentLineups
            .receive(on: DispatchQueue.main)
            .sink { [weak self] lineups in
                self?.reloadRecent(lineups)
            }
            .store(in: &cancelBag)
    }

    private func buildTemplates() {
        templatesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for formation in viewModel.formations {
            let card = makeFormationTemplateCard(formation)
            templatesStack.addArrangedSubview(card)
            card.snp.makeConstraints { $0.width.equalTo(100) }
        }
    }

    private func buildShortcuts() {
        shortcutsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let items: [(String, Selector)] = [
            (L10n.Football.Home.Shortcut.editor, #selector(didTapShortcutEditor)),
            (L10n.Football.Home.Shortcut.tactics, #selector(didTapShortcutTactics)),
            (L10n.Football.Home.Shortcut.export, #selector(didTapShortcutExport)),
        ]
        for (title, action) in items {
            let button = FootballNeonButton(title: title, style: .secondary)
            button.addTarget(self, action: action, for: .touchUpInside)
            shortcutsStack.addArrangedSubview(button)
        }
    }

    private func reloadRecent(_ lineups: [FootballLineup]) {
        recentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for lineup in lineups.prefix(3) {
            let card = FootballGlassView()
            let label = UILabel()
            label.text = lineup.displayTitle
            label.font = FootballPalette.title(15)
            label.textColor = FootballPalette.textPrimary
            card.addSubview(label)
            label.snp.makeConstraints { $0.edges.equalToSuperview().inset(Spacing.s16) }
            card.snp.makeConstraints { $0.height.equalTo(56) }
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapRecent(_:)))
            card.addGestureRecognizer(tap)
            card.tag = lineups.firstIndex(where: { $0.id == lineup.id }) ?? 0
            recentStack.addArrangedSubview(card)
        }
    }

    private func makeFormationTemplateCard(_ formation: FootballFormation) -> UIView {
        let card = FootballGlassView()
        let preview = FootballFormationPreviewView(formation: formation)
        let label = UILabel()
        label.text = formation.name
        label.font = FootballPalette.caption()
        label.textColor = FootballPalette.textPrimary
        label.textAlignment = .center
        card.addSubview(preview)
        card.addSubview(label)
        preview.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(Spacing.s8)
            make.height.equalTo(70)
        }
        label.snp.makeConstraints { make in
            make.top.equalTo(preview.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview().inset(Spacing.s8)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapTemplate(_:)))
        card.addGestureRecognizer(tap)
        card.accessibilityLabel = formation.id
        return card
    }

    @objc private func didTapCreate() {
        viewModel.createNewLineup()
        onCreateLineup?()
    }

    @objc private func didTapRecent(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view,
              viewModel.recentLineups.indices.contains(view.tag) else { return }
        let lineup = viewModel.recentLineups[view.tag]
        viewModel.openLineup(lineup)
        onOpenLineup?(lineup)
    }

    @objc private func didTapTemplate(_ gesture: UITapGestureRecognizer) {
        guard let id = gesture.view?.accessibilityLabel,
              let formation = FootballFormation.catalog.first(where: { $0.id == id }) else { return }
        viewModel.createNewLineup()
        LineupStore.shared.applyFormation(formation)
        onCreateLineup?()
    }

    @objc private func didTapShortcutEditor() { onOpenEditor?() }
    @objc private func didTapShortcutTactics() { onOpenTactics?() }
    @objc private func didTapShortcutExport() { onOpenExport?() }

    @objc private func didTapClose() { onClose?() }
}
