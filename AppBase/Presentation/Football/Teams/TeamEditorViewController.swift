//
//  TeamEditorViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import SnapKit
import UIKit

/// Sơ đồ đội (sân + dự bị), không vẽ chiến thuật.
final class TeamEditorViewController: FootballScreenViewController<TeamEditorViewModel> {

    var onPickPlayer: ((Int, @escaping (FootballPlayer) -> Void) -> Void)?
    var onPickFormation: (() -> Void)?
    var onSaved: (() -> Void)?

    private let headerBar = UIView()
    private let backButton = UIButton(type: .system)
    private let headerTitleLabel = UILabel()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let nameField = UITextField()
    private let pitchSizeStack = UIStackView()
    private var pitchSizeButtons: [MatchPitchSizeButton] = []
    private let formationButton = UIButton(type: .system)
    private let pitchCard = UIView()
    private let pitchView = FootballPitchView()
    private let hintLabel = UILabel()
    private let benchTitleLabel = UILabel()
    private let benchRow = UIView()
    private let benchStack = UIStackView()
    private let saveButton = UIButton(type: .system)

    private var playerTokens: [FootballPlayerTokenView] = []
    private var benchTokens: [FootballPlayerTokenView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func setupUI() {
        super.setupUI()
        buildHeader()
        buildForm()
        buildPitch()
        buildBench()
        buildSave()
        layoutChrome()
        syncPitchSizeSelection()
        reloadSquad()
        
    }

    override func refreshLocalization() {
        headerTitleLabel.text = L10n.Football.Teams.editorTitle
        hintLabel.text = L10n.Football.Teams.tapSlotHint
        benchTitleLabel.text = L10n.Football.Editor.benchPlayers
        formationButton.setTitle(L10n.Football.Teams.pickFormation, for: .normal)
        saveButton.setTitle(L10n.Football.Teams.save.uppercased(), for: .normal)
        nameField.placeholder = L10n.Football.Teams.namePlaceholder
    }

    override func onBind() {
        super.onBind()
        viewModel.$team
            .receive(on: DispatchQueue.main)
            .sink { [weak self] team in
                self?.nameField.text = team.name
                self?.syncPitchSizeSelection()
                self?.reloadSquad()
            }
            .store(in: &cancelBag)

        viewModel.slotTap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                self?.onPickPlayer?(index) { player in
                    TeamStore.shared.assignPlayer(player, pitchSlot: index)
                }
            }
            .store(in: &cancelBag)

        viewModel.benchTap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                self?.onPickPlayer?(index) { player in
                    TeamStore.shared.setBenchPlayer(player, at: index)
                }
            }
            .store(in: &cancelBag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutPitchTokens()
    }

    // MARK: - Build

    private func buildHeader() {
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = FootballPalette.textPrimary
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        headerTitleLabel.font = FootballPalette.title(17)
        headerTitleLabel.textColor = FootballPalette.textPrimary
        headerTitleLabel.textAlignment = .center

        headerBar.addSubview(backButton)
        headerBar.addSubview(headerTitleLabel)
        view.addSubview(headerBar)

        backButton.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(44)
        }
        headerTitleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualTo(backButton.snp.trailing)
            make.trailing.lessThanOrEqualToSuperview().inset(44)
        }
        headerBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(Spacing.s12)
            make.height.equalTo(48)
        }
    }

    private func buildForm() {
        contentStack.axis = .vertical
        contentStack.spacing = Spacing.s12

        nameField.font = FootballPalette.title(16)
        nameField.textColor = FootballPalette.textPrimary
        nameField.backgroundColor = FootballPalette.surface
        nameField.layer.cornerRadius = Radius.s12
        nameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        nameField.leftViewMode = .always
        nameField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)

        pitchSizeStack.axis = .horizontal
        pitchSizeStack.spacing = Spacing.s10
        pitchSizeStack.distribution = .fillEqually
        pitchSizeButtons = MatchPitchSize.allCases.map { size in
            let button = MatchPitchSizeButton(size: size)
            button.addTarget(self, action: #selector(pitchSizeTapped(_:)), for: .touchUpInside)
            pitchSizeStack.addArrangedSubview(button)
            return button
        }

        formationButton.titleLabel?.font = FootballPalette.title(15)
        formationButton.setTitleColor(FootballPalette.textPrimary, for: .normal)
        formationButton.backgroundColor = FootballPalette.surface
        formationButton.layer.cornerRadius = Radius.s12
        formationButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        formationButton.addTarget(self, action: #selector(formationTapped), for: .touchUpInside)

        contentStack.addArrangedSubview(nameField)
        contentStack.addArrangedSubview(pitchSizeStack)
        contentStack.addArrangedSubview(formationButton)
        nameField.snp.makeConstraints { $0.height.equalTo(48) }
    }

    private func buildPitch() {
        pitchCard.backgroundColor = FootballPalette.surface
        pitchCard.layer.cornerRadius = Radius.s16
        pitchCard.addSubview(pitchView)
        
        pitchView.displayOptions = .init(showsGrid: true)
        
        hintLabel.font = FootballPalette.caption()
        hintLabel.textColor = FootballPalette.textSecondary
        hintLabel.numberOfLines = 0

        pitchView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.s12)
            make.height.equalTo(pitchView.snp.width).dividedBy(FootballPitchView.fieldWidthToHeightRatio)
        }

        contentStack.addArrangedSubview(pitchCard)
        contentStack.addArrangedSubview(hintLabel)

        scrollView.addSubview(contentStack)
        view.addSubview(scrollView)
    }

    private func buildBench() {
        benchTitleLabel.font = FootballPalette.caption()
        benchTitleLabel.textColor = FootballPalette.textSecondary

        benchStack.axis = .horizontal
        benchStack.distribution = .fillEqually
        benchRow.addSubview(benchStack)
        benchStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(FootballPlayerTokenSize.bench.circleDiameter + 20)
        }

        contentStack.addArrangedSubview(benchTitleLabel)
        contentStack.addArrangedSubview(benchRow)
    }

    private func buildSave() {
        saveButton.backgroundColor = FootballPalette.accentRed
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = FootballPalette.title(16)
        saveButton.layer.cornerRadius = Radius.s12
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        view.addSubview(saveButton)
    }

    private func layoutChrome() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerBar.snp.bottom).offset(Spacing.s8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(saveButton.snp.top).offset(-Spacing.s12)
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
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Spacing.s16)
            make.height.equalTo(52)
        }
    }

    // MARK: - Squad

    private func reloadSquad() {
        playerTokens.forEach { $0.removeFromSuperview() }
        playerTokens.removeAll()
        benchTokens.removeAll()
        benchStack.arrangedSubviews.forEach {
            benchStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let team = viewModel.team
        for assignment in team.assignments {
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

        for index in 0..<MatchTeamRoster.benchSlotCount {
            let token = FootballPlayerTokenView(
                slotIndex: index,
                player: TeamStore.shared.benchPlayer(at: index),
                size: .bench
            )
            token.delegate = self
            token.allowsDrag = false
            benchTokens.append(token)
            let cell = UIView()
            cell.addSubview(token)
            token.snp.makeConstraints { $0.center.equalToSuperview() }
            benchStack.addArrangedSubview(cell)
        }

        view.setNeedsLayout()
        view.layoutIfNeeded()
        layoutPitchTokens()
    }

    private func layoutPitchTokens() {
        PitchPlayerTokenLayout.layout(playerTokens, formation: viewModel.team.formation, in: pitchView)
    }

    private func syncPitchSizeSelection() {
        pitchSizeButtons.forEach { $0.isSelected = $0.pitchSize == viewModel.team.pitchSize }
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func nameChanged() {
        viewModel.updateName(nameField.text ?? "")
    }

    @objc private func pitchSizeTapped(_ sender: MatchPitchSizeButton) {
        viewModel.setPitchSize(sender.pitchSize)
    }

    @objc private func formationTapped() {
        onPickFormation?()
    }

    @objc private func saveTapped() {
        viewModel.save()
        onSaved?()
    }
}

extension TeamEditorViewController: FootballPlayerTokenViewDelegate {

    func playerTokenDidMove(_ token: FootballPlayerTokenView, normalizedPosition: CGPoint) {}

    func playerTokenDidTap(_ token: FootballPlayerTokenView) {
        if benchTokens.contains(where: { $0 === token }) {
            viewModel.benchTap.send(token.slotIndex)
            return
        }
        guard token.slotIndex >= 0 else { return }
        viewModel.slotTap.send(token.slotIndex)
    }
}
