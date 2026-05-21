//
//  TacticalModeViewController.swift
//  AppBase
//

import SnapKit
import UIKit
import BaseMVVM

/// Full-screen tactical board with drawing tools.
final class TacticalModeViewController: FootballScreenViewController<LineupEditorViewModel> {

    private let pitchView = FootballPitchView()
    private let overlay = TacticalDrawingOverlay()
    private let toolbar = FootballGlassView()
    private let hintLabel = UILabel()

    override func setupUI() {
        super.setupUI()
        title = L10n.Football.Tactics.title
        hintLabel.text = L10n.Football.Tactics.hint
        hintLabel.font = FootballPalette.body(13)
        hintLabel.textColor = FootballPalette.textSecondary
        hintLabel.numberOfLines = 0

        view.addSubview(hintLabel)
        view.addSubview(pitchView)
        pitchView.addSubview(overlay)
        view.addSubview(toolbar)

        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.s12)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
        }
        pitchView.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(Spacing.s12)
            make.leading.trailing.equalToSuperview().inset(Spacing.s16)
            make.height.equalTo(pitchView.snp.width).multipliedBy(1.3)
        }
        overlay.snp.makeConstraints { $0.edges.equalToSuperview() }
        toolbar.snp.makeConstraints { make in
            make.top.equalTo(pitchView.snp.bottom).offset(Spacing.s16)
            make.leading.trailing.equalTo(pitchView)
            make.height.equalTo(52)
        }

        overlay.strokes = LineupStore.shared.tacticalStrokes
        buildToolbar()
    }

    private func buildToolbar() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Spacing.s8
        stack.distribution = .fillEqually
        toolbar.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(Spacing.s8) }

        let arrow = FootballNeonButton(title: L10n.Football.Tactics.Tool.arrow, style: .secondary)
        let zone = FootballNeonButton(title: L10n.Football.Tactics.Tool.zone, style: .secondary)
        let clear = FootballNeonButton(title: L10n.Football.Tactics.Tool.clear, style: .destructive)
        zone.addAction(UIAction { [weak self] _ in
            var options = LineupStore.shared.tacticalLineOptions
            options.color = .red
            self?.overlay.lineOptions = options
        }, for: .touchUpInside)
        arrow.addAction(UIAction { [weak self] _ in
            var options = LineupStore.shared.tacticalLineOptions
            options.color = .white
            self?.overlay.lineOptions = options
        }, for: .touchUpInside)
        clear.addAction(UIAction { [weak self] _ in
            self?.overlay.clear()
        }, for: .touchUpInside)
        [arrow, zone, clear].forEach { stack.addArrangedSubview($0) }
    }
}
