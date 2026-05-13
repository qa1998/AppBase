//
//  PlayScriptViewController.swift
//  AppBase
//

import BaseMVVM
import SnapKit
import UIKit

final class PlayScriptViewController: TIOViewController<PlayScriptViewModel> {

    // MARK: Views

    private let textView = UITextView()

    // Fade
    private let topFadeView = UIView()

    private let bottomFadeView = UIView()

    private lazy var highlightManager =
        HighlightManager(
            textView: textView
        )

    private lazy var scrollController =
        TeleprompterScrollController(
            textView: textView
        )

    private let timerLabel = UILabel()

    private let progressLabel = UILabel()

    private let mirrorButton =
        UIButton(type: .system)

    private let voiceButton =
        UIButton(type: .system)

    private let exportButton =
        UIButton(type: .system)

    private let bottomPanel = UIView()

    private let playPauseButton =
        UIButton(type: .system)

    // MARK: Init

    init(script: TeleprompterScript) {

        super.init(
            nibName: nil,
            bundle: nil
        )

        invoke(
            viewModel:
                PlayScriptViewModel(
                    script: script
                )
        )
    }

    required init?(coder: NSCoder) {

        fatalError(
            "init(coder:) has not been implemented"
        )
    }

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        highlightManager.reset(
            fullText: viewModel.script.content,
            fontSize: viewModel.fontSize
        )
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        if isMovingFromParent ||
            navigationController?.isBeingDismissed == true {

            viewModel.stopPlayback()
        }
    }

    override func setupUI() {

        super.setupUI()

        view.backgroundColor =
            ThemeManager.shared.colors.teleprompterBackground

        configureNavigationBar()

        setupTextView()

        setupBottomPanel()

        setupTopBar()

        setupFadeMask()

        setupGestures()
    }

    override func onBind() {

        super.onBind()

        viewModel.onProgressTick = {
            [weak self]
            elapsed,
            progress in

            self?.timerLabel.text =
                Self.formatTime(elapsed)

            self?.progressLabel.text =
                L10n.teleprompterSettingsPercentFormat(
                    Float(progress * 100)
                )
        }

        viewModel.onPlayStateChanged = {
            [weak self]
            playing in

            self?.updatePlayButton(
                isPlaying: playing
            )
        }

        viewModel.onSpokenRange = {
            [weak self]
            range,
            _ in

            guard let self else {
                return
            }

            highlightManager.updateCurrentRange(
                range
            )

            scrollController.updateTargetForCharacterRange(
                range
            )
        }

        viewModel.onSeekToCharacter = {
            [weak self]
            offset in

            self?.highlightManager.applyStaticProgress(
                upTo: offset
            )

            self?.scrollToOffset(
                offset
            )
        }

        viewModel.onFontSizeChanged = {
            [weak self]
            fontSize in

            self?.highlightManager.refreshAttributesKeepingRanges(
                fontSize: fontSize
            )
        }

        viewModel.onExportStateChanged = {
            [weak self]
            isExporting in

            self?.updateExportButton(
                isExporting: isExporting
            )
        }

        viewModel.onVoiceChanged = {
            [weak self]
            voiceName in

            self?.voiceButton.accessibilityLabel =
                L10n.teleprompterVoiceAccessibility(
                    voiceName
                )
        }
    }

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        topFadeView.layer.sublayers?.first?.frame =
            topFadeView.bounds

        bottomFadeView.layer.sublayers?.first?.frame =
            bottomFadeView.bounds
    }

    // MARK: Setup

    private func setupTextView() {

        textView.backgroundColor =
            ThemeManager.shared.colors.teleprompterBackground

        textView.isEditable = false

        textView.isSelectable = false

        textView.isScrollEnabled = true

        textView.showsVerticalScrollIndicator = false

        textView.textContainer.lineFragmentPadding = 0

        textView.contentInsetAdjustmentBehavior = .never

        view.addSubview(textView)

        view.addSubview(topFadeView)

        view.addSubview(bottomFadeView)

        textView.snp.makeConstraints {

            $0.top.equalTo(
                view.safeAreaLayoutGuide.snp.top
            ).offset(56)

            $0.leading.trailing.equalToSuperview()

            $0.bottom.equalToSuperview()
        }

        // TOP FADE

        topFadeView.snp.makeConstraints {

            $0.top.equalTo(textView)

            $0.leading.trailing.equalToSuperview()

            $0.height.equalTo(120)
        }

        // FIX CRASH HERE

        bottomFadeView.snp.makeConstraints {

            $0.leading.trailing.equalToSuperview()

            $0.bottom.equalToSuperview()

            $0.height.equalTo(240)
        }
    }

    private func setupBottomPanel() {

        bottomPanel.backgroundColor =
            ThemeManager.shared.colors.teleprompterPanelBackground

        view.addSubview(bottomPanel)

        bottomPanel.snp.makeConstraints {

            $0.leading.trailing.bottom.equalToSuperview()

            $0.height.equalTo(112)
        }

        bottomPanel.isUserInteractionEnabled = true

        configurePlayButton()

        bottomPanel.addSubview(playPauseButton)

        playPauseButton.addTarget(
            self,
            action: #selector(onTogglePlay),
            for: .touchUpInside
        )

        playPauseButton.snp.makeConstraints {

            $0.centerX.equalToSuperview()

            $0.centerY.equalToSuperview()

            $0.width.height.equalTo(72)
        }

        // IMPORTANT
        view.bringSubviewToFront(bottomPanel)
    }

    private func setupTopBar() {

        view.addSubview(timerLabel)

        view.addSubview(progressLabel)

        view.addSubview(mirrorButton)

        view.addSubview(voiceButton)

        view.addSubview(exportButton)

        mirrorButton.setImage(
            UIImage(
                systemName:
                    "rectangle.split.2x1"
            ),
            for: .normal
        )

        mirrorButton.addTarget(
            self,
            action: #selector(toggleMirror),
            for: .touchUpInside
        )

        voiceButton.setImage(
            UIImage(
                systemName:
                    "speaker.wave.2.fill"
            ),
            for: .normal
        )

        voiceButton.accessibilityLabel =
            L10n.teleprompterVoiceSelectAccessibility

        voiceButton.addTarget(
            self,
            action: #selector(onSelectVoice),
            for: .touchUpInside
        )

        exportButton.setImage(
            UIImage(
                systemName:
                    "square.and.arrow.down"
            ),
            for: .normal
        )

        let colors =
            ThemeManager.shared.colors

        mirrorButton.tintColor =
            colors.teleprompterControlTint

        voiceButton.tintColor =
            colors.teleprompterControlTint

        exportButton.tintColor =
            colors.teleprompterControlTint

        exportButton.addTarget(
            self,
            action: #selector(onExportSpeech),
            for: .touchUpInside
        )

        timerLabel.font =
            .monospacedDigitSystemFont(
                ofSize: 17,
                weight: .semibold
            )

        timerLabel.textColor =
            colors.teleprompterTextCurrent

        timerLabel.text = "00:00:00"

        progressLabel.font =
            .systemFont(
                ofSize: 13,
                weight: .medium
            )

        progressLabel.textColor =
            colors.teleprompterTextRead

        progressLabel.text = "0%"

        mirrorButton.snp.makeConstraints {

            $0.leading.equalToSuperview()
                .offset(12)

            $0.top.equalTo(
                view.safeAreaLayoutGuide.snp.top
            ).offset(4)

            $0.width.height.equalTo(40)
        }

        voiceButton.snp.makeConstraints {

            $0.leading.equalTo(mirrorButton.snp.trailing)
                .offset(4)

            $0.centerY.equalTo(mirrorButton)

            $0.width.height.equalTo(40)
        }

        timerLabel.snp.makeConstraints {

            $0.centerX.equalToSuperview()

            $0.centerY.equalTo(mirrorButton)
        }

        exportButton.snp.makeConstraints {

            $0.trailing.equalToSuperview()
                .offset(-12)

            $0.centerY.equalTo(mirrorButton)

            $0.width.height.equalTo(40)
        }

        progressLabel.snp.makeConstraints {

            $0.trailing.equalTo(exportButton.snp.leading)
                .offset(-8)

            $0.centerY.equalTo(mirrorButton)
        }

        // IMPORTANT
        view.bringSubviewToFront(timerLabel)

        view.bringSubviewToFront(progressLabel)

        view.bringSubviewToFront(mirrorButton)

        view.bringSubviewToFront(voiceButton)

        view.bringSubviewToFront(exportButton)
    }

    // MARK: Fade

    private func setupFadeMask() {

        // TOP

        let topGradient =
            CAGradientLayer()

        topGradient.colors = [

            ThemeManager
                .shared
                .colors
                .teleprompterBackground
                .cgColor,

            UIColor.clear.cgColor
        ]

        topGradient.startPoint =
            CGPoint(x: 0.5, y: 0)

        topGradient.endPoint =
            CGPoint(x: 0.5, y: 1)

        topFadeView.layer.addSublayer(
            topGradient
        )

        // BOTTOM

        let bottomGradient =
            CAGradientLayer()

        bottomGradient.colors = [

            UIColor.clear.cgColor,

            ThemeManager
                .shared
                .colors
                .teleprompterBackground
                .cgColor
        ]

        bottomGradient.startPoint =
            CGPoint(x: 0.5, y: 0)

        bottomGradient.endPoint =
            CGPoint(x: 0.5, y: 1)

        bottomFadeView.layer.addSublayer(
            bottomGradient
        )

        topFadeView.isUserInteractionEnabled = false

        bottomFadeView.isUserInteractionEnabled = false
    }

    private func setupGestures() {

        let doubleTap =
            UITapGestureRecognizer(
                target: self,
                action: #selector(onDoubleTap)
            )

        doubleTap.numberOfTapsRequired = 2

        textView.addGestureRecognizer(
            doubleTap
        )

        let pan =
            UIPanGestureRecognizer(
                target: self,
                action: #selector(onPanTextView)
            )

        pan.cancelsTouchesInView = false
        pan.delegate = self

        textView.addGestureRecognizer(
            pan
        )

        let longPress =
            UILongPressGestureRecognizer(
                target: self,
                action: #selector(onLongPressTextView)
            )

        longPress.minimumPressDuration = 0.35

        textView.addGestureRecognizer(
            longPress
        )
    }

    // MARK: Navigation

    private func configureNavigationBar() {

        navigationController?
            .navigationBar
            .tintColor =
            ThemeManager.shared.colors.teleprompterControlTint

        let appearance =
            UINavigationBarAppearance()

        appearance.configureWithOpaqueBackground()

        appearance.backgroundColor =
            ThemeManager.shared.colors.teleprompterBackground

        appearance.shadowColor = .clear

        navigationController?
            .navigationBar
            .standardAppearance = appearance

        navigationController?
            .navigationBar
            .scrollEdgeAppearance = appearance

        let settingsItem =
            UIBarButtonItem(
                image: UIImage(
                    systemName: "gearshape.fill"
                ),
                style: .plain,
                target: self,
                action: #selector(onOpenSettings)
            )

        settingsItem.accessibilityLabel =
            L10n.teleprompterSettingsAccessibility

        navigationItem.rightBarButtonItem =
            settingsItem
    }

    // MARK: Buttons

    private func configurePlayButton() {

        let colors =
            ThemeManager.shared.colors

        playPauseButton.backgroundColor =
            colors.teleprompterPlayButtonBackground

        playPauseButton.tintColor =
            colors.teleprompterPlayButtonTint

        playPauseButton.layer.cornerRadius = 36

        playPauseButton.setImage(
            UIImage(
                systemName:
                    "play.fill"
            ),
            for: .normal
        )
    }

    // MARK: Actions

    @objc
    private func onTogglePlay() {

        viewModel.togglePlayPause()
    }

    @objc
    private func onDoubleTap() {

        viewModel.togglePlayPause()
    }

    @objc
    private func onPanTextView(
        _ gesture: UIPanGestureRecognizer
    ) {

        guard gesture.state == .ended else {
            return
        }

        let translation =
            gesture.translation(
                in: textView
            )

        guard abs(translation.y) > abs(translation.x),
              abs(translation.y) > 24
        else {
            return
        }

        scrollController.scrollLeadFactor =
            min(
                1.8,
                max(
                    0.4,
                    scrollController.scrollLeadFactor
                    - translation.y / 500
                )
            )
    }

    @objc
    private func onLongPressTextView(
        _ gesture: UILongPressGestureRecognizer
    ) {

        guard gesture.state == .began else {
            return
        }

        let point =
            gesture.location(
                in: textView
            )

        let index =
            characterIndex(
                at: point
            )

        viewModel.seekToCharacter(
            index
        )
    }

    @objc
    private func onSelectVoice() {

        presentVoicePicker()
    }

    @objc
    private func onOpenSettings() {

        let vc =
            PlayScriptSettingsViewController(
                speechRateMultiplier: viewModel.speechRateMultiplier,
                fontSize: viewModel.fontSize
            )

        vc.onSpeechRateChanged = {
            [weak self, weak vc]
            value in

            guard let self else {
                return
            }

            viewModel.setSpeechRateMultiplier(
                value
            )

            vc?.updateValues(
                speechRateMultiplier: viewModel.speechRateMultiplier,
                fontSize: viewModel.fontSize
            )
        }

        vc.onFontSizeChanged = {
            [weak self, weak vc]
            value in

            guard let self else {
                return
            }

            viewModel.setFontSize(
                value
            )

            vc?.updateValues(
                speechRateMultiplier: viewModel.speechRateMultiplier,
                fontSize: viewModel.fontSize
            )
        }

        let navigationController =
            UINavigationController(
                rootViewController: vc
            )

        navigationController.modalPresentationStyle = .pageSheet

        if let sheet =
            navigationController.sheetPresentationController {

            sheet.detents = [
                .medium()
            ]

            sheet.prefersGrabberVisible = true
        }

        present(
            navigationController,
            animated: true
        )
    }

    @objc
    private func onExportSpeech() {

        viewModel.exportSpeechToFile {
            [weak self]
            result in

            guard let self else {
                return
            }

            switch result {
            case let .success(fileURL):
                presentExportShareSheet(
                    fileURL: fileURL
                )

            case let .failure(error):
                presentExportError(
                    error
                )
            }
        }
    }

    @objc
    private func toggleMirror() {

        viewModel.mirrorEnabled.toggle()

        let sx: CGFloat =
            viewModel.mirrorEnabled
            ? -1
            : 1

        textView.transform =
            CGAffineTransform(
                scaleX: sx,
                y: 1
            )

        mirrorButton.tintColor =
            viewModel.mirrorEnabled
            ? ThemeManager.shared.colors.teleprompterActiveAccent
            : ThemeManager.shared.colors.teleprompterControlTint
    }

    // MARK: UI

    private func updatePlayButton(
        isPlaying: Bool
    ) {

        let name =
            isPlaying
            ? "pause.fill"
            : "play.fill"

        playPauseButton.setImage(
            UIImage(systemName: name),
            for: .normal
        )
    }

    private func updateExportButton(
        isExporting: Bool
    ) {

        exportButton.isEnabled =
            !isExporting

        exportButton.alpha =
            isExporting
            ? 0.5
            : 1

        let imageName =
            isExporting
            ? "hourglass"
            : "square.and.arrow.down"

        exportButton.setImage(
            UIImage(
                systemName: imageName
            ),
            for: .normal
        )
    }

    private func presentExportShareSheet(
        fileURL: URL
    ) {

        let vc =
            UIActivityViewController(
                activityItems: [
                    fileURL
                ],
                applicationActivities: nil
            )

        vc.popoverPresentationController?.sourceView =
            exportButton

        vc.popoverPresentationController?.sourceRect =
            exportButton.bounds

        present(
            vc,
            animated: true
        )
    }

    private func presentExportError(
        _ error: Error
    ) {

        let alert =
            UIAlertController(
                title: L10n.teleprompterExportErrorTitle,
                message: error.localizedDescription,
                preferredStyle: .alert
            )

        alert.addAction(
            UIAlertAction(
                title: L10n.commonOK,
                style: .default
            )
        )

        present(
            alert,
            animated: true
        )
    }

    private func presentVoicePicker() {

        let options =
            viewModel.availableVoiceOptions()

        guard !options.isEmpty else {

            let alert =
                UIAlertController(
                    title: L10n.teleprompterVoiceEmptyTitle,
                    message: L10n.teleprompterVoiceEmptyMessage,
                    preferredStyle: .alert
                )

            alert.addAction(
                UIAlertAction(
                    title: L10n.commonOK,
                    style: .default
                )
            )

            present(
                alert,
                animated: true
            )
            return
        }

        let sheet =
            UIAlertController(
                title: L10n.teleprompterVoicePickerTitle,
                message: L10n.teleprompterVoicePickerMessage,
                preferredStyle: .actionSheet
            )

        options.forEach {
            option in

            let title =
                option.isSelected
                ? L10n.teleprompterVoicePickerSelectedFormat(
                    option.title,
                    option.subtitle
                )
                : L10n.teleprompterVoicePickerOptionFormat(
                    option.title,
                    option.subtitle
                )

            sheet.addAction(
                UIAlertAction(
                    title: title,
                    style: .default
                ) {
                    [weak self]
                    _ in

                    self?.viewModel.selectVoice(
                        identifier: option.identifier
                    )
                }
            )
        }

        sheet.addAction(
            UIAlertAction(
                title: L10n.commonCancel,
                style: .cancel
            )
        )

        sheet.popoverPresentationController?.sourceView =
            voiceButton

        sheet.popoverPresentationController?.sourceRect =
            voiceButton.bounds

        present(
            sheet,
            animated: true
        )
    }

    private func scrollToOffset(
        _ offset: Int
    ) {

        let length =
            textView.textStorage.length

        guard length > 0 else {
            return
        }

        let location =
            max(
                0,
                min(
                    offset,
                    max(
                        0,
                        length - 1
                    )
                )
            )

        scrollController.updateTargetForCharacterRange(
            NSRange(
                location: location,
                length: 1
            )
        )
    }

    private func characterIndex(
        at point: CGPoint
    ) -> Int {

        textView.layoutManager.ensureLayout(
            for: textView.textContainer
        )

        var textContainerPoint = point

        textContainerPoint.x +=
            textView.contentOffset.x
            - textView.textContainerInset.left

        textContainerPoint.y +=
            textView.contentOffset.y
            - textView.textContainerInset.top

        let glyphIndex =
            textView.layoutManager.glyphIndex(
                for: textContainerPoint,
                in: textView.textContainer
            )

        return textView.layoutManager.characterIndexForGlyph(
            at: glyphIndex
        )
    }

    private static func formatTime(
        _ t: TimeInterval
    ) -> String {

        let s = Int(t)

        let h = s / 3600

        let m =
            (s % 3600) / 60

        let sec =
            s % 60

        return String(
            format:
                "%02d:%02d:%02d",
            h,
            m,
            sec
        )
    }
}

extension PlayScriptViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {

        true
    }
}
