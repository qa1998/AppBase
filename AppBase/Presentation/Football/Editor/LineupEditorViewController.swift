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
    var onPickFormation: (() -> Void)?
    var onPickPitchOptions: (() -> Void)?
    var onPickLineOptions: (() -> Void)?
    var onSaveLineup: (() -> Void)?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private let formationButton = UIButton(type: .system)
    private let arrowsButton = UIButton(type: .system)
//    private let toolTabBar = EditorToolTabBar()
    private let pitchCard = UIView()
    private let pitchView = FootballPitchView()
    private let drawingOverlay = TacticalDrawingOverlay()
    private var playerTokens: [FootballPlayerTokenView] = []
    
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
    
    override func setupUI() {
        super.setupUI()
        buildFormationButton()
        buildArrowsButton()
        buildPitchCard()
        buildBenchSection()
        buildSaveButton()
        layoutContent()
        wireDrawingOverlay()
//        toolTabBar.selectedMode = .fields
        setToolMode(.fields)
        syncDrawingOverlayStrokes()
        updateTacticalActions()
        refreshLocalization()
    }
    
    override func refreshLocalization() {
        benchTitleLabel.text = L10n.Football.Editor.benchPlayers
        saveButton.setTitle(L10n.Football.Editor.save.uppercased(), for: .normal)
//        toolTabBar.refreshTitles()
    }
    
    override func refreshFootballTheme() {
        super.refreshFootballTheme()
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
        
        formationButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.onPickFormation?()}
            .store(in: &cancelBag)
        
        arrowsButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.onPickLineOptions?()}
            .store(in: &cancelBag)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTokens()
    }
    
    // MARK: - Build
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
        formationButton.tintColor = .white
        formationButton.setTitleColor(.white, for: .normal)
        formationButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        
        formationButton.backgroundColor = UIColor(red: 18/255, green: 25/255, blue: 32/255, alpha: 1)
        formationButton.layer.cornerRadius = 14
        formationButton.layer.borderWidth = 1
        formationButton.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        formationButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        formationButton.setContentHuggingPriority(.required, for: .horizontal)
        
        view.addSubview(formationButton)
        
        formationButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.s8)
            make.leading.equalToSuperview().inset(Spacing.s16)
            make.height.equalTo(38)
        }
    }
    
    private func buildArrowsButton() {
        var config = UIButton.Configuration.plain()
        config.title = "Draw"
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
        arrowsButton.tintColor = .white
        arrowsButton.setTitleColor(.white, for: .normal)
        arrowsButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        
        arrowsButton.backgroundColor = UIColor(red: 18/255, green: 25/255, blue: 32/255, alpha: 1)
        arrowsButton.layer.cornerRadius = 14
        arrowsButton.layer.borderWidth = 1
        arrowsButton.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
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
        saveButton.setTitleColor(.white, for: .normal)
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
                .multipliedBy(1.28)
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
            
            token.snp.makeConstraints { make in
                make.size.equalTo(FootballPlayerTokenSize.pitch.viewSize)
            }
            
            playerTokens.append(token)
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        layoutTokens()
    }
    
    private func layoutTokens() {
        let bounds = pitchView.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }
        
        for token in playerTokens {
            let p = token.normalizedPosition
            let x = p.x * bounds.width
            let y = p.y * bounds.height
            
            token.snp.remakeConstraints { make in
                make.size.equalTo(token.tokenSize.viewSize)
                make.centerX.equalToSuperview().offset(x - bounds.width / 2)
                make.centerY.equalToSuperview().offset(y - bounds.height / 2)
            }
        }
    }
    
    private func reloadBench() {
        benchStack.arrangedSubviews.forEach {
            benchStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        let players = viewModel.benchPlayers
        
        for index in 0..<LineupEditorViewModel.benchSlotCount {
            let token = FootballPlayerTokenView(
                slotIndex: -1,
                player: index < players.count ? players[index] : nil,
                size: .bench
            )
            
            token.allowsDrag = false
            
            let cell = makeBenchCell(token)
            benchStack.addArrangedSubview(cell)
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
        guard token.slotIndex >= 0 else { return }
        viewModel.slotTap.send(token.slotIndex)
    }
}
