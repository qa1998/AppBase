//
//  LineupShareViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import SnapKit
import UIKit

/// Share preview — flat pitch or 3D perspective, then system share sheet.
final class LineupShareViewController: FootballScreenViewController<LineupShareViewModel> {

    private let backgroundGradient = CAGradientLayer()
    private let shareCard = UIView()
    
    private let pitchStage = UIView()
    private let pitchView = FootballPitchView()
    private let drawingOverlay = TacticalDrawingOverlay()
    private var playerTokens: [FootballPlayerTokenView] = []
    private let shareButton = UIButton(type: .system)

    private let viewModeStrip = UIView()
    private let viewModeStack = UIStackView()
    private let flatModeButton = UIButton(type: .system)
    private let view3DModeButton = UIButton(type: .system)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func setupUI() {
        super.setupUI()
        setupBackground()
        buildViewModeToggle()
        buildPitchStage()
        buildShareButton()
        layoutViews()
        reloadLineupContent()
        updateViewModeButtonTitles()
        syncViewModeButtons()
        refreshLocalization()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyPitchMode(viewModel.pitchMode)
    }

    override func onBind() {
        super.onBind()
        viewModel.$pitchMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mode in
                self?.applyPitchMode(mode)
                self?.syncViewModeButtons()
            }
            .store(in: &cancelBag)
    }

    override func refreshLocalization() {
        navigationItem.title = L10n.Football.Share.title
        shareButton.setTitle(L10n.Football.Share.shareAction, for: .normal)
        updateViewModeButtonTitles()
        syncViewModeButtons()
        reloadHeader()
    }

    override func refreshFootballTheme() {
        super.refreshFootballTheme()
        shareButton.backgroundColor = FootballPalette.accentRed
        viewModeStrip.layer.borderColor = FootballPalette.glassBorder.cgColor
        syncViewModeButtons()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
        layoutPlayerTokens()
    }

    // MARK: - Build

    private func setupBackground() {
        backgroundGradient.colors = [
            UIColor(hex: 0x0A1F1A).cgColor,
            UIColor(hex: 0x0F1115).cgColor,
            UIColor(hex: 0x0A1218).cgColor,
        ]
        backgroundGradient.locations = [0, 0.45, 1]
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }

    private func buildViewModeToggle() {
        viewModeStrip.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        viewModeStrip.layer.cornerRadius = Radius.s12
        viewModeStrip.layer.borderWidth = 1
        viewModeStrip.layer.borderColor = FootballPalette.glassBorder.cgColor

        viewModeStack.axis = .horizontal
        viewModeStack.spacing = 4
        viewModeStack.distribution = .fillEqually

        [flatModeButton, view3DModeButton].forEach { button in
            button.layer.cornerRadius = Radius.s8
            button.titleLabel?.font = FootballPalette.caption(12)
            button.addTarget(self, action: #selector(viewModeTapped(_:)), for: .touchUpInside)
            configureViewModeButton(button)
            viewModeStack.addArrangedSubview(button)
        }
        flatModeButton.tag = LineupSharePitchMode.flat.rawValue
        view3DModeButton.tag = LineupSharePitchMode.perspective3D.rawValue

        viewModeStrip.addSubview(viewModeStack)
        view.addSubview(viewModeStrip)
        viewModeStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        flatModeButton.snp.makeConstraints { $0.width.greaterThanOrEqualTo(88) }
        view3DModeButton.snp.makeConstraints { $0.width.greaterThanOrEqualTo(88) }
    }

    private func configureViewModeButton(_ button: UIButton) {
        var config = UIButton.Configuration.plain()
        config.imagePadding = 6
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
        config.imagePlacement = .leading
        button.configuration = config
    }
    
    private func buildPitchStage() {
        pitchStage.clipsToBounds = false
        pitchView.isUserInteractionEnabled = false
        drawingOverlay.isUserInteractionEnabled = false
        pitchStage.addSubview(pitchView)
        pitchStage.addSubview(drawingOverlay)
        shareCard.clipsToBounds = false
        shareCard.addSubview(pitchStage)
    }

    private func buildShareButton() {
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.titleLabel?.font = FootballPalette.title(17)
        shareButton.backgroundColor = FootballPalette.accentRed
        shareButton.layer.cornerRadius = Radius.s12
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        view.addSubview(shareButton)
    }

    private func layoutViews() {
        viewModeStrip.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.s8)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }

        view.addSubview(shareCard)
        shareCard.snp.makeConstraints { make in
            make.top.equalTo(viewModeStrip.snp.bottom).offset(Spacing.s12)
            make.leading.trailing.equalToSuperview().inset(Spacing.s16)
            make.bottom.equalTo(shareButton.snp.top).offset(-Spacing.s20)
        }

       

        pitchStage.snp.makeConstraints { make in
            make.top.equalTo(viewModeStrip.snp.bottom).offset(Spacing.s12)
            make.leading.trailing.bottom.equalToSuperview()
        }
        pitchView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(pitchView.snp.width).dividedBy(FootballPitchView.fieldWidthToHeightRatio)
        }
        drawingOverlay.snp.makeConstraints { make in
            make.edges.equalTo(pitchView)
        }
        shareButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Spacing.s16)
            make.height.equalTo(52)
        }
    }

    // MARK: - Content

    private func reloadLineupContent() {
        reloadHeader()
        reloadPitchDisplay()
        reloadTokens()
        layoutPlayerTokens()
    }

    private func reloadHeader() {
        let lineup = viewModel.lineup
    }

    private func reloadPitchDisplay() {
        let lineup = viewModel.lineup
        pitchView.displayOptions = lineup.pitchDisplayOptions
        drawingOverlay.strokes = lineup.tacticalDrawing.strokes
        drawingOverlay.lineOptions = lineup.tacticalLineOptions
    }

    private func reloadTokens() {
        playerTokens.forEach { $0.removeFromSuperview() }
        playerTokens.removeAll()
        for assignment in viewModel.lineup.assignments {
            let token = FootballPlayerTokenView(
                slotIndex: assignment.slotIndex,
                player: assignment.player
            )
            token.normalizedPosition = assignment.normalizedPosition
            token.isUserInteractionEnabled = false
            pitchView.addSubview(token)
            playerTokens.append(token)
        }
    }

    private func layoutPlayerTokens() {
        PitchPlayerTokenLayout.layout(
            playerTokens,
            formation: viewModel.lineup.formation,
            in: pitchView
        )
    }

    // MARK: - View mode

    private func applyPitchMode(_ mode: LineupSharePitchMode) {
        guard pitchStage.bounds.width > 0 else { return }
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseInOut]) {
            switch mode {
            case .flat:
                self.pitchStage.layer.transform = CATransform3DIdentity
            case .perspective3D:
                var transform = CATransform3DIdentity
                transform.m34 = -1 / 650
                let angle: CGFloat = 48 * .pi / 180
                transform = CATransform3DRotate(transform, angle, 1, 0, 0)
                transform = CATransform3DScale(transform, 0.88, 0.88, 1)
                self.pitchStage.layer.transform = transform
            }
        }
    }

    private func updateViewModeButtonTitles() {
        flatModeButton.configuration?.title = L10n.Football.Share.viewFlat
        flatModeButton.configuration?.image = UIImage(systemName: "square.split.2x1")
        view3DModeButton.configuration?.title = L10n.Football.Share.view3D
        view3DModeButton.configuration?.image = UIImage(systemName: "cube")
    }

    private func syncViewModeButtons() {
        let selectedBg = FootballPalette.accentRed.withAlphaComponent(0.4)
        let normalBg = UIColor.clear
        let selectedTint = FootballPalette.accentRed
        let normalTint = FootballPalette.textPrimary

        func style(_ button: UIButton, selected: Bool) {
            button.backgroundColor = selected ? selectedBg : normalBg
            button.tintColor = selected ? selectedTint : normalTint
            button.configuration?.baseForegroundColor = selected ? selectedTint : normalTint
        }
        style(flatModeButton, selected: viewModel.pitchMode == .flat)
        style(view3DModeButton, selected: viewModel.pitchMode == .perspective3D)
    }

    @objc private func viewModeTapped(_ sender: UIButton) {
        guard let mode = LineupSharePitchMode(rawValue: sender.tag) else { return }
        viewModel.pitchMode = mode
    }

    @objc private func shareTapped() {
        shareCard.layoutIfNeeded()
        let renderer = UIGraphicsImageRenderer(bounds: shareCard.bounds)
        let image = renderer.image { ctx in
            shareCard.layer.render(in: ctx.cgContext)
        }
        let activity = UIActivityViewController(
            activityItems: [image, viewModel.lineup.displayTitle],
            applicationActivities: nil
        )
        if let popover = activity.popoverPresentationController {
            popover.sourceView = shareButton
            popover.sourceRect = shareButton.bounds
        }
        present(activity, animated: true)
    }
}
