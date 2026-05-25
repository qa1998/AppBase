//
//  LineupEditorViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import SnapKit
import UIKit

final class LineupEditorViewController: FootballScreenViewController<LineupEditorViewModel> {
    
    var onPickPlayer: ((Int) -> Void)?
    var onPickBenchPlayer: ((Int) -> Void)?
    var onPickFormation: (() -> Void)?
    var onPickPitchOptions: (() -> Void)?
    var onPickLineOptions: (() -> Void)?
    var onSaveLineup: (() -> Void)?
    var onImportTeam: (() -> Void)?
    var onPickSettings: (() -> Void)?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private let formationButton = UIButton(type: .system)
    private let importTeamButton = UIButton(type: .system)
    private let arrowsButton = UIButton(type: .system)
    private let pitchCard = UIView()
    private let pitchView = FootballPitchView()
    private let drawingOverlay = TacticalDrawingOverlay()
    private var playerTokens: [FootballPlayerTokenView] = []
    private var benchTokens: [FootballPlayerTokenView] = []
    
    private let benchHeader = UIView()
    private let benchTitleLabel = UILabel()
    private let tacticalActionsStack = UIStackView()
    private let undoButton = UIButton(type: .system)
    private let redoButton = UIButton(type: .system)
    private let trashButton = UIButton(type: .system)
    private let benchRow = UIView()
    private let benchStack = UIStackView()
    
    private let saveButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var navSetting: NavigationSetting {
        var setting = super.navSetting
        setting.title = viewModel.displayTitle
        let rightBar  = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsTapped)
        )
        setting.rightButtons = [rightBar]
        return setting
    }
    
    override func setupUI() {
        super.setupUI()
        buildFormationButton()
        buildArrowsButton()
        buildImportTeamButton()
        buildPitchCard()
        buildBenchSection()
        buildSaveButton()
        layoutContent()
        wireDrawingOverlay()
        setToolMode(.fields)
        syncDrawingOverlayStrokes()
        updateTacticalActions()
        refreshLocalization()
    }
    
    override func refreshLocalization() {
        super.refreshLocalization()
        benchTitleLabel.text = L10n.Football.Editor.benchPlayers
        saveButton.setTitle(L10n.Football.Editor.save.uppercased(), for: .normal)
        importTeamButton.configuration?.title = L10n.Football.Editor.importTeam
        arrowsButton.configuration?.title = L10n.Football.Editor.draw
        reloadFormation(viewModel.lineup)
        reloadBench()
    }
    
    override func refreshFootballTheme() {
        super.refreshFootballTheme()
        styleHeaderChip(importTeamButton)
        benchTitleLabel.textColor = FootballPalette.textSecondary
        updateTacticalActions()
        trashButton.tintColor = FootballPalette.accentRed
        saveButton.backgroundColor = FootballPalette.accentRed
        applyPitchOptions()
        applyLineOptionsToOverlay()
        pitchView.setNeedsDisplay()
        reloadPitch(viewModel.lineup)
        reloadBench()
    }
    
    override func onBind() {
        super.onBind()
        viewModel.$lineup
            .receive(on: DispatchQueue.main)
            .sink { [weak self] lineup in
                self?.refreshNavigationTitle()
                self?.reloadFormation(lineup)
                self?.reloadPitch(lineup)
                self?.reloadBench()
            }
            .store(in: &cancelBag)
        
        viewModel.$hasTacticalStrokes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.syncDrawingOverlayStrokes()
                self?.updateTacticalActions()
            }
            .store(in: &cancelBag)
        viewModel.$canUndoStroke
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateTacticalActions() }
            .store(in: &cancelBag)
        viewModel.$canRedoStroke
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateTacticalActions() }
            .store(in: &cancelBag)
        
        viewModel.slotTap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                self?.onPickPlayer?(index)
            }
            .store(in: &cancelBag)

        viewModel.benchTap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                self?.onPickBenchPlayer?(index)
            }
            .store(in: &cancelBag)
        
        formationButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.onPickFormation?()}
            .store(in: &cancelBag)
        
        arrowsButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.onPickLineOptions?()}
            .store(in: &cancelBag)

        importTeamButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.onImportTeam?() }
            .store(in: &cancelBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTokens()
    }


    private func refreshNavigationTitle() {
        setupNavigation(navSetting)
    }

    @objc private func settingsTapped() {
        onPickSettings?()
    }

    // MARK: - Build
    private func styleHeaderChip(_ button: UIButton) {
        button.tintColor = FootballPalette.onAccent
        button.setTitleColor(FootballPalette.textPrimary, for: .normal)
        button.backgroundColor = FootballPalette.surfaceElevated
        button.layer.borderColor = FootballPalette.glassBorder.cgColor
        button.layer.borderWidth = 1
    }

    private func buildFormationButton() {
        var config = UIButton.Configuration.plain()
        config.title = "4-3-3"
        config.image = UIImage(systemName: "chevron.down", withConfiguration: symbolConfig(pointSize: 12, weight: .semibold))
        config.imagePlacement = .trailing
        config.imagePadding = Spacing.s8
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 12,
            bottom: 0,
            trailing: 12
        )
        
        formationButton.configuration = config
        formationButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        formationButton.layer.cornerRadius = 14
        formationButton.layer.borderWidth = 1
        styleHeaderChip(formationButton)
        formationButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        formationButton.setContentHuggingPriority(.required, for: .horizontal)
        
        view.addSubview(formationButton)
        
        formationButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.s8)
            make.leading.equalToSuperview().inset(Spacing.s16)
            make.height.equalTo(38)
        }
    }
    
    private func buildImportTeamButton() {
        var config = UIButton.Configuration.plain()
        config.title = L10n.Football.Editor.importTeam
        config.image = UIImage(systemName: "person.3.fill", withConfiguration: symbolConfig(pointSize: 12, weight: .semibold))
        config.imagePlacement = .leading
        config.imagePadding = Spacing.s6
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        importTeamButton.configuration = config
        importTeamButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        importTeamButton.layer.cornerRadius = 14
        importTeamButton.layer.borderWidth = 1
        styleHeaderChip(importTeamButton)
        importTeamButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        view.addSubview(importTeamButton)

        importTeamButton.snp.makeConstraints { make in
            make.centerY.height.equalTo(formationButton)
            make.leading.equalTo(formationButton.snp.trailing).offset(Spacing.s8)
            make.trailing.lessThanOrEqualTo(arrowsButton.snp.leading).offset(-Spacing.s8)
        }
    }

    private func buildArrowsButton() {
        var config = UIButton.Configuration.plain()
        config.title = L10n.Football.Editor.draw
        config.image = UIImage(named: "ic-arrow-top-right")?.resized(to: .square(size: 16))
        config.imagePlacement = .trailing
        config.imagePadding = Spacing.s8
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 12,
            bottom: 0,
            trailing: 12
        )
        
        arrowsButton.configuration = config
        arrowsButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        arrowsButton.layer.cornerRadius = 14
        arrowsButton.layer.borderWidth = 1
        styleHeaderChip(arrowsButton)
        arrowsButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        arrowsButton.setContentHuggingPriority(.required, for: .horizontal)
        
        view.addSubview(arrowsButton)
        
        arrowsButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.s8)
            make.right.equalToSuperview().inset(Spacing.s16)
            make.height.equalTo(38)
        }
    }
    private func buildToolTabs() {
//        toolTabBar.onModeChanged = { [weak self] mode in
//            self?.applyToolMode(mode, presentOptions: true)
//        }
//        view.addSubview(toolTabBar)
    }
    
    private func buildPitchCard() {
        pitchCard.backgroundColor = FootballPalette.surface
        pitchCard.layer.cornerRadius = Radius.s16
        pitchCard.addSubview(pitchView)
        pitchView.addSubview(drawingOverlay)
        drawingOverlay.passThroughHost = pitchView
        applyPitchOptions()
        applyLineOptionsToOverlay()
        view.addSubview(pitchCard)
    }
    
    private func buildBenchSection() {
        benchTitleLabel.font = FootballPalette.caption()
        benchTitleLabel.textColor = FootballPalette.textSecondary
        
        tacticalActionsStack.axis = .horizontal
        tacticalActionsStack.spacing = Spacing.s12
        tacticalActionsStack.alignment = .center
        tacticalActionsStack.isHidden = true
        
        undoButton.setImage(
            UIImage(systemName: "arrow.uturn.backward",
                    withConfiguration: symbolConfig(pointSize: 17, weight: .semibold)),
            for: .normal
        )
        
        redoButton.setImage(
            UIImage(systemName: "arrow.uturn.forward",
                    withConfiguration: symbolConfig(pointSize: 17, weight: .semibold)),
            for: .normal
        )
        
        trashButton.setImage(
            UIImage(systemName: "trash",
                    withConfiguration: symbolConfig(pointSize: 17, weight: .medium)),
            for: .normal
        )
        
        trashButton.tintColor = FootballPalette.accentRed
        
        [undoButton, redoButton, trashButton].forEach {
            $0.contentMode = .scaleAspectFit
        }
        
        undoButton.addTarget(self, action: #selector(didTapUndo), for: .touchUpInside)
        redoButton.addTarget(self, action: #selector(didTapRedo), for: .touchUpInside)
        trashButton.addTarget(self, action: #selector(didTapTrash), for: .touchUpInside)
        
        tacticalActionsStack.addArrangedSubview(undoButton)
        tacticalActionsStack.addArrangedSubview(redoButton)
        tacticalActionsStack.addArrangedSubview(trashButton)
        
        [undoButton, redoButton, trashButton].forEach {
            $0.snp.makeConstraints { make in
                make.size.equalTo(28)
            }
        }
        
        benchStack.axis = .horizontal
        benchStack.distribution = .fillEqually
        benchStack.alignment = .fill
        benchStack.spacing = 0
        
        benchRow.clipsToBounds = false
        benchStack.clipsToBounds = false
        
        benchRow.addSubview(benchStack)
        benchStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        benchHeader.addSubview(benchTitleLabel)
        benchHeader.addSubview(tacticalActionsStack)
        
        tacticalActionsStack.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
        }
        
        view.addSubview(benchHeader)
        view.addSubview(benchRow)
    }
    
    private func buildSaveButton() {
        saveButton.backgroundColor = FootballPalette.accentRed
        saveButton.setTitleColor(FootballPalette.onAccent, for: .normal)
        saveButton.titleLabel?.font = FootballPalette.title(16)
        saveButton.layer.cornerRadius = Radius.s12
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        view.addSubview(saveButton)
    }
    
    private func layoutContent() {
//        toolTabBar.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.s12)
//            make.leading.trailing.equalToSuperview().inset(Spacing.s16)
//            make.height.equalTo(72)
//        }
        
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.height.equalTo(52)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Spacing.s12)
        }
        
        benchRow.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.height.equalTo(72)
            make.bottom.equalTo(saveButton.snp.top).offset(-Spacing.s12)
        }
        
        benchHeader.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.height.equalTo(24)
            make.bottom.equalTo(benchRow.snp.top).offset(-Spacing.s6)
        }
        
        benchTitleLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        
        tacticalActionsStack.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
        }
        
        pitchCard.snp.makeConstraints { make in
            make.top.equalTo(formationButton.snp.bottom).offset(Spacing.s8)
            make.leading.trailing.equalToSuperview().inset(Spacing.s16)
            make.bottom.equalTo(benchHeader.snp.top).offset(-Spacing.s12)
        }
        
        pitchView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(Spacing.s10)
            make.bottom.equalToSuperview().inset(Spacing.s10)
            make.height.equalTo(pitchView.snp.width)
                .dividedBy(FootballPitchView.fieldWidthToHeightRatio)
                .priority(.medium)
        }
        
        drawingOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    // MARK: - Pitch & bench
    
    private func wireDrawingOverlay() {
        drawingOverlay.onStrokeWillCommit = { [weak self] in
            self?.viewModel.prepareStrokeCommit()
        }
        drawingOverlay.onStrokeCommitted = { [weak self] in
            self?.viewModel.strokeCommitted()
            self?.syncDrawingOverlayStrokes()
            self?.updateTacticalActions()
        }
    }
    
    private func applyToolMode(_ mode: EditorToolMode, presentOptions: Bool) {
        setToolMode(mode)
        guard presentOptions else { return }
        switch mode {
        case .formation:
            onPickFormation?()
        case .fields:
            onPickPitchOptions?()
        case .arrows:
            onPickLineOptions?()
        }
    }
    
    private func setToolMode(_ mode: EditorToolMode) {
        let displayMode: EditorToolMode = mode == .formation ? .fields : mode
//        toolTabBar.selectedMode = mode
        viewModel.selectedTool = displayMode
        
        drawingOverlay.isHidden = false
        drawingOverlay.isUserInteractionEnabled = true
        applyPitchOptions()
        applyLineOptionsToOverlay()
    }
    
    func refreshPitchAndLineOptions() {
        applyPitchOptions()
        applyLineOptionsToOverlay()
        pitchView.setNeedsDisplay()
        drawingOverlay.setNeedsDisplay()
    }
    
    private func applyPitchOptions() {
        pitchView.displayOptions = LineupStore.shared.pitchDisplayOptions
    }
    
    func applyLineOptionsToOverlay() {
        drawingOverlay.lineOptions = LineupStore.shared.tacticalLineOptions
    }
    
    private func syncDrawingOverlayStrokes() {
        drawingOverlay.strokes = LineupStore.shared.tacticalStrokes
        drawingOverlay.setNeedsDisplay()
    }
    
    private func updateTacticalActions() {
        let hasStrokes = viewModel.hasTacticalStrokes
        tacticalActionsStack.isHidden = !hasStrokes
        styleTacticalButton(undoButton, enabled: viewModel.canUndoStroke)
        styleTacticalButton(redoButton, enabled: viewModel.canRedoStroke)
        trashButton.alpha = hasStrokes ? 1 : 0.4
    }
    
    private func styleTacticalButton(_ button: UIButton, enabled: Bool) {
        button.isEnabled = enabled
        button.tintColor = enabled
        ? FootballPalette.textPrimary
        : FootballPalette.textSecondary.withAlphaComponent(0.35)
    }
    
    private func symbolConfig(pointSize: CGFloat, weight: UIImage.SymbolWeight) -> UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
    }
    
    func reloadFormation(_ lineup: FootballLineup) {
        formationButton.configuration?.title = lineup.formation.name
    }
    
    private func reloadPitch(_ lineup: FootballLineup) {
        playerTokens.forEach { $0.removeFromSuperview() }
        playerTokens.removeAll()
        
        for assignment in lineup.assignments {
            let token = FootballPlayerTokenView(
                slotIndex: assignment.slotIndex,
                player: assignment.player,
                size: .pitch
            )
            
            token.normalizedPosition = assignment.normalizedPosition
            token.delegate = self
            token.allowsDrag = false
            token.translatesAutoresizingMaskIntoConstraints = false
            pitchView.addSubview(token)
            playerTokens.append(token)
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        layoutTokens()
    }
    
    private func layoutTokens() {
        PitchPlayerTokenLayout.layout(playerTokens, formation: viewModel.lineup.formation, in: pitchView)
    }
    
    private func reloadBench() {
        benchStack.arrangedSubviews.forEach {
            benchStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        benchTokens.removeAll()

        for index in 0..<LineupEditorViewModel.benchSlotCount {
            let token = FootballPlayerTokenView(
                slotIndex: index,
                player: viewModel.benchPlayer(at: index),
                size: .bench
            )
            token.delegate = self
            token.allowsDrag = false
            benchTokens.append(token)

            let cell = makeBenchCell(token)
            cell.tag = index
            let longPress = UILongPressGestureRecognizer(
                target: self,
                action: #selector(benchLongPressed(_:))
            )
            longPress.minimumPressDuration = 0.5
            cell.addGestureRecognizer(longPress)
            benchStack.addArrangedSubview(cell)
        }
    }

    @objc private func benchLongPressed(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let cell = gesture.view,
              viewModel.benchPlayer(at: cell.tag) != nil else { return }
        LineupStore.shared.setBenchPlayer(nil, at: cell.tag)
    }
    
    private func makeBenchCell(_ content: UIView) -> UIView {
        let cell = UIView()
        
        cell.addSubview(content)
        
        content.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return cell
    }
    // MARK: - Actions
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapTrophy() {
        viewModel.presentSuccess(L10n.Football.Lineups.premiumHint)
    }
    
    @objc private func didTapUndo() {
        viewModel.undoStroke()
        syncDrawingOverlayStrokes()
        updateTacticalActions()
    }
    
    @objc private func didTapRedo() {
        viewModel.redoStroke()
        syncDrawingOverlayStrokes()
        updateTacticalActions()
    }
    
    @objc private func didTapTrash() {
        viewModel.clearTacticalDrawings()
        syncDrawingOverlayStrokes()
        setToolMode(.fields)
        updateTacticalActions()
    }
    
    @objc private func didTapSave() {
        viewModel.save()
        onSaveLineup?()
    }
}

extension LineupEditorViewController: FootballPlayerTokenViewDelegate {
    
    func playerTokenDidMove(_ token: FootballPlayerTokenView, normalizedPosition: CGPoint) {
        LineupStore.shared.moveSlot(token.slotIndex, to: normalizedPosition)
    }
    
    func playerTokenDidTap(_ token: FootballPlayerTokenView) {
        if benchTokens.contains(where: { $0 === token }) {
            viewModel.benchTap.send(token.slotIndex)
            return
        }
        guard token.slotIndex >= 0 else { return }
        viewModel.slotTap.send(token.slotIndex)
    }
}
