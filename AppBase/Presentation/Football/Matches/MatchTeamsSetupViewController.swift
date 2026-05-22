//
//  MatchTeamsSetupViewController.swift
//  AppBase
//

import BaseMVVM
import SnapKit
import UIKit

/// Configure home / away squads on pitch + bench (tap slot → pick player).
final class MatchTeamsSetupViewController: FootballScreenViewController<CreateMatchViewModel> {

    var onFinished: (() -> Void)?
    var onPickPlayer: ((MatchTeamSide, MatchRosterSlot, @escaping (FootballPlayer) -> Void) -> Void)?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let segment = UISegmentedControl(items: [
        L10n.Football.Match.Create.homeTeam,
        L10n.Football.Match.Create.awayTeam,
    ])
    private let pitchCard = UIView()
    private let pitchView = FootballPitchView()
    private let hintLabel = UILabel()
    private let benchTitleLabel = UILabel()
    private let benchRow = UIView()
    private let benchStack = UIStackView()
    private let progressLabel = UILabel()
    private let confirmButton = UIButton(type: .system)
    private var playerTokens: [FootballPlayerTokenView] = []
    private var benchTokens: [FootballPlayerTokenView] = []
    private var editingSide: MatchTeamSide = .home

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func setupUI() {
        super.setupUI()
        title = L10n.Football.Match.Create.setupTeams

        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        pitchCard.backgroundColor = FootballPalette.surface
        pitchCard.layer.cornerRadius = Radius.s16
        pitchCard.addSubview(pitchView)

        hintLabel.font = FootballPalette.caption()
        hintLabel.textColor = FootballPalette.textSecondary
        hintLabel.text = L10n.Football.Match.Create.tapSlotHint
        hintLabel.numberOfLines = 0

        benchTitleLabel.font = FootballPalette.caption()
        benchTitleLabel.textColor = FootballPalette.textSecondary
        benchTitleLabel.text = L10n.Football.Editor.benchPlayers

        benchStack.axis = .horizontal
        benchStack.distribution = .fillEqually
        benchStack.alignment = .fill
        benchStack.spacing = 0
        benchRow.addSubview(benchStack)
        benchStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(FootballPlayerTokenSize.bench.fixedTokenHeight)
        }

        progressLabel.font = FootballPalette.caption()
        progressLabel.textColor = FootballPalette.textSecondary
        progressLabel.numberOfLines = 0

        confirmButton.setTitle(L10n.Football.Match.Create.confirm, for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = FootballPalette.title(16)
        confirmButton.backgroundColor = FootballPalette.accentRed
        confirmButton.layer.cornerRadius = Radius.s12
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        contentStack.axis = .vertical
        contentStack.spacing = Spacing.s12
        contentStack.addArrangedSubview(pitchCard)
        contentStack.addArrangedSubview(hintLabel)
        contentStack.addArrangedSubview(benchTitleLabel)
        contentStack.addArrangedSubview(benchRow)
        contentStack.addArrangedSubview(progressLabel)

        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.addSubview(contentStack)

        view.addSubview(segment)
        view.addSubview(scrollView)
        view.addSubview(confirmButton)

        segment.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.s12)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
        }
        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Spacing.s16)
            make.height.equalTo(52)
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(segment.snp.bottom).offset(Spacing.s12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(confirmButton.snp.top).offset(-Spacing.s12)
        }
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(
                top: 0,
                left: Spacing.s16,
                bottom: Spacing.s16,
                right: Spacing.s16
            ))
            make.width.equalTo(scrollView.frameLayoutGuide).offset(-Spacing.s32)
        }
        pitchView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.s12)
            make.height.equalTo(pitchView.snp.width).dividedBy(FootballPitchView.fieldWidthToHeightRatio)
        }

        reloadSquad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutPitchTokens()
    }

    @objc private func segmentChanged() {
        editingSide = segment.selectedSegmentIndex == 0 ? .home : .away
        reloadSquad()
    }

    private func reloadSquad() {
        reloadPitch()
        reloadBench()
        updateProgress()
    }

    private func reloadPitch() {
        playerTokens.forEach { $0.removeFromSuperview() }
        playerTokens.removeAll()

        let roster = viewModel.roster(for: editingSide)
        for assignment in roster.assignments {
            let token = FootballPlayerTokenView(
                slotIndex: assignment.slotIndex,
                player: assignment.player,
                size: .pitch
            )
            token.normalizedPosition = assignment.normalizedPosition
            token.delegate = self
            token.allowsDrag = false
            pitchView.addSubview(token)
            playerTokens.append(token)
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()
        layoutPitchTokens()
    }

    private func layoutPitchTokens() {
        let roster = viewModel.roster(for: editingSide)
        let formation = FootballFormation.catalog.first { $0.id == roster.formationId }
            ?? FootballFormation.default
        PitchPlayerTokenLayout.layout(playerTokens, formation: formation, in: pitchView)
    }

    private func reloadBench() {
        benchStack.arrangedSubviews.forEach {
            benchStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        benchTokens.removeAll()

        let roster = viewModel.roster(for: editingSide)
        for index in 0..<MatchTeamRoster.benchSlotCount {
            let token = FootballPlayerTokenView(
                slotIndex: index,
                player: roster.benchPlayer(at: index),
                size: .bench
            )
            token.allowsDrag = false
            token.delegate = self
            benchTokens.append(token)
            benchStack.addArrangedSubview(makeBenchCell(token))
        }
    }

    private func makeBenchCell(_ content: UIView) -> UIView {
        let cell = UIView()
        cell.addSubview(content)
        content.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return cell
    }

    private func updateProgress() {
        let roster = viewModel.roster(for: editingSide)
        progressLabel.text = L10n.Football.Match.Create.teamRosterProgress(
            roster.filledPitchSlots,
            roster.assignments.count,
            roster.filledBenchSlots,
            MatchTeamRoster.benchSlotCount
        )
    }

    @objc private func confirmTapped() {
        guard viewModel.createMatch() != nil else { return }
        onFinished?()
    }

    private func openPicker(for slot: MatchRosterSlot) {
        onPickPlayer?(editingSide, slot) { [weak self] player in
            guard let self else { return }
            self.viewModel.assignPlayer(player, to: slot, side: self.editingSide)
            self.reloadSquad()
        }
    }
}

extension MatchTeamsSetupViewController: FootballPlayerTokenViewDelegate {

    func playerTokenDidMove(_ token: FootballPlayerTokenView, normalizedPosition: CGPoint) {}

    func playerTokenDidTap(_ token: FootballPlayerTokenView) {
        if benchTokens.contains(where: { $0 === token }) {
            openPicker(for: .bench(token.slotIndex))
            return
        }
        guard token.slotIndex >= 0 else { return }
        openPicker(for: .pitch(token.slotIndex))
    }
}
