//
//  RecordOverlayViewController.swift
//  AppBase
//

import SnapKit
import UIKit
import AVFoundation

final class RecordOverlayViewController: UIViewController {

    private enum ReadMode: Int {
        case manual
        case auto
    }

    var onFinishRecording: ((URL, TimeInterval) -> Void)?

    private static let selectedVoiceIdentifierKey =
        "teleprompter.selectedVoiceIdentifier"

    private let script: TeleprompterScript
    private let outputURL: URL
    private let recorder = ScriptVideoRecorder()
    private let speech = SpeechManager()

    private let previewView = UIView()
    private let closeButton = UIButton(type: .system)
    private let switchButton = UIButton(type: .system)
    private let timerLabel = UILabel()
    private lazy var readModeControl =
        UISegmentedControl(
            items: [
                L10n.recordReadModeManual,
                L10n.recordReadModeAuto
            ]
        )
    private let scriptCard = UIView()
    private let scriptTextView = UITextView()
    private lazy var scriptScrollController =
        TeleprompterScrollController(
            textView: scriptTextView
        )
    private let recordButton = UIButton(type: .system)
    private let pauseButton = UIButton(type: .system)
    private let doneButton = UIButton(type: .system)
    private let speedLabel = UILabel()

    private var timer: Timer?
    private var manualScrollDisplayLink: CADisplayLink?
    private var lastManualScrollTimestamp: CFTimeInterval?
    private var activeStartedAt: Date?
    private var accumulatedRecordingTime: TimeInterval = 0
    private var isRecording = false
    private var isRecordingPaused = false
    private var readMode: ReadMode = .manual
    private var currentReadRange: NSRange?
    private var readEndUTF16 = 0
    private let scriptFont =
        UIFont.systemFont(
            ofSize: 18,
            weight: .semibold
        )

    init(
        script: TeleprompterScript,
        outputURL: URL
    ) {

        self.script = script
        self.outputURL = outputURL

        super.init(
            nibName: nil,
            bundle: nil
        )

        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {

        fatalError(
            "init(coder:) has not been implemented"
        )
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        setupUI()
        setupSpeech()
        requestPermissionsAndConfigure()
    }

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        recorder.updatePreviewFrame(
            previewView.bounds
        )
    }

    override func viewWillDisappear(
        _ animated: Bool
    ) {

        super.viewWillDisappear(
            animated
        )

        timer?.invalidate()
        stopManualScriptScroll()
        speech.stop()
        recorder.stopSession()
    }

    private func setupUI() {

        view.backgroundColor = .black
        previewView.backgroundColor = .black

        view.addSubview(previewView)
        view.addSubview(closeButton)
        view.addSubview(switchButton)
        view.addSubview(timerLabel)
        view.addSubview(readModeControl)
        view.addSubview(scriptCard)
        view.addSubview(recordButton)
        view.addSubview(pauseButton)
        view.addSubview(doneButton)
        view.addSubview(speedLabel)

        previewView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        setupTopControls()
        setupReadModeControl()
        setupScriptCard()
        setupBottomControls()
    }

    private func setupTopControls() {

        closeButton.setImage(
            UIImage(
                systemName: "xmark"
            ),
            for: .normal
        )
        closeButton.tintColor = .white
        closeButton.backgroundColor =
            UIColor.black.withAlphaComponent(
                0.35
            )
        closeButton.layer.cornerRadius = 18
        closeButton.addTarget(
            self,
            action: #selector(onClose),
            for: .touchUpInside
        )

        switchButton.setImage(
            UIImage(
                systemName: "camera.rotate"
            ),
            for: .normal
        )
        switchButton.tintColor = .white
        switchButton.backgroundColor =
            UIColor.black.withAlphaComponent(
                0.35
            )
        switchButton.layer.cornerRadius = 18
        switchButton.addTarget(
            self,
            action: #selector(onSwitchCamera),
            for: .touchUpInside
        )

        timerLabel.text = "00:00:00"
        timerLabel.textColor = .white
        timerLabel.font =
            .monospacedDigitSystemFont(
                ofSize: 16,
                weight: .semibold
            )

        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
                .offset(18)
            $0.top.equalTo(
                view.safeAreaLayoutGuide.snp.top
            ).offset(8)
            $0.width.height.equalTo(36)
        }

        switchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
                .offset(-18)
            $0.centerY.equalTo(closeButton)
            $0.width.height.equalTo(36)
        }

        timerLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(closeButton)
        }
    }

    private func setupReadModeControl() {

        readModeControl.selectedSegmentIndex =
            ReadMode.manual.rawValue
        readModeControl.backgroundColor =
            UIColor.black.withAlphaComponent(
                0.35
            )
        readModeControl.selectedSegmentTintColor =
            UIColor.white.withAlphaComponent(
                0.9
            )
        readModeControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(
                    ofSize: 13,
                    weight: .semibold
                )
            ],
            for: .normal
        )
        readModeControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(
                    ofSize: 13,
                    weight: .semibold
                )
            ],
            for: .selected
        )
        readModeControl.accessibilityLabel =
            L10n.recordReadModeAccessibility
        readModeControl.addTarget(
            self,
            action: #selector(onReadModeChanged),
            for: .valueChanged
        )

        readModeControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(closeButton.snp.bottom)
                .offset(12)
            $0.width.equalTo(220)
            $0.height.equalTo(34)
        }
    }

    private func setupScriptCard() {

        scriptCard.backgroundColor =
            UIColor.black.withAlphaComponent(
                0.48
            )
        scriptCard.layer.cornerRadius = 12

        scriptTextView.backgroundColor = .clear
        scriptTextView.isEditable = false
        scriptTextView.isSelectable = false
        scriptTextView.isScrollEnabled = true
        scriptTextView.showsVerticalScrollIndicator = false
        scriptTextView.textContainerInset =
            UIEdgeInsets(
                top: 12,
                left: 12,
                bottom: 12,
                right: 12
            )
        scriptTextView.textContainer.lineFragmentPadding = 0
        scriptTextView.contentInsetAdjustmentBehavior = .never
        resetScriptTextProgress()

        scriptCard.addSubview(
            scriptTextView
        )

        scriptCard.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
                .inset(32)
            $0.bottom.equalTo(recordButton.snp.top)
                .offset(-36)
            $0.height.equalTo(132)
        }

        scriptTextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setupBottomControls() {

        recordButton.backgroundColor = .systemRed
        recordButton.tintColor = .white
        recordButton.layer.cornerRadius = 34
        recordButton.layer.borderColor =
            UIColor.white.withAlphaComponent(
                0.85
            ).cgColor
        recordButton.layer.borderWidth = 4
        recordButton.setImage(
            UIImage(
                systemName: "record.circle.fill"
            ),
            for: .normal
        )
        recordButton.addTarget(
            self,
            action: #selector(onToggleRecord),
            for: .touchUpInside
        )

        pauseButton.setImage(
            UIImage(
                systemName: "pause.fill"
            ),
            for: .normal
        )
        pauseButton.tintColor = .white
        pauseButton.backgroundColor =
            UIColor.black.withAlphaComponent(
                0.42
            )
        pauseButton.layer.cornerRadius = 28
        pauseButton.isHidden = true
        pauseButton.addTarget(
            self,
            action: #selector(onTogglePause),
            for: .touchUpInside
        )

        doneButton.setImage(
            UIImage(
                systemName: "checkmark.square"
            ),
            for: .normal
        )
        doneButton.tintColor = .white
        doneButton.setTitle(
            "\n\(L10n.recordDone)",
            for: .normal
        )
        doneButton.titleLabel?.font =
            .systemFont(
                ofSize: 12,
                weight: .medium
            )
        doneButton.titleLabel?.numberOfLines = 2
        doneButton.addTarget(
            self,
            action: #selector(onDone),
            for: .touchUpInside
        )

        speedLabel.text = L10n.recordSpeedWPM
        speedLabel.textColor =
            UIColor.white.withAlphaComponent(
                0.75
            )
        speedLabel.font =
            .systemFont(
                ofSize: 13,
                weight: .medium
            )

        recordButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(
                view.safeAreaLayoutGuide.snp.bottom
            ).offset(-54)
            $0.width.height.equalTo(68)
        }

        pauseButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
                .offset(36)
            $0.centerY.equalTo(recordButton)
            $0.width.height.equalTo(56)
        }

        doneButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
                .offset(-36)
            $0.centerY.equalTo(recordButton)
            $0.width.height.equalTo(64)
        }

        speedLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(recordButton.snp.bottom)
                .offset(18)
        }
    }

    private func requestPermissionsAndConfigure() {

        recorder.requestPermissions {
            [weak self]
            result in

            guard let self else {
                return
            }

            switch result {
            case .success:
                configureRecorder()

            case let .failure(error):
                presentError(
                    error.localizedDescription
                )
            }
        }
    }

    private func configureRecorder() {

        do {

            try recorder.configurePreview(
                in: previewView
            )

            recorder.startSession()

        } catch {

            presentError(
                error.localizedDescription
            )
        }
    }

    private func startRecording() {

        activeStartedAt = Date()
        accumulatedRecordingTime = 0
        isRecording = true
        isRecordingPaused = false
        updateRecordButton()
        updatePauseButton()
        startTimer()
        configureRecordingAudioSession()

        recorder.startRecording(
            to: outputURL
        ) {
            [weak self]
            result in

            DispatchQueue.main.async {
                self?.handleRecordingFinished(
                    result
                )
            }
        }

        startAutoReadIfNeeded(
            delayed: true
        )

        if readMode == .manual {
            resetScriptTextProgress()
            startManualScriptScroll()
        }
    }

    private func stopRecording() {

        guard isRecording else {
            return
        }

        speech.stop()
        stopManualScriptScroll()
        timer?.invalidate()
        recorder.stopRecording()
    }

    private func pauseRecording() {

        guard isRecording,
              !isRecordingPaused
        else {
            return
        }

        recorder.pauseRecording()
        accumulatedRecordingTime =
            currentRecordingElapsed()
        activeStartedAt = nil
        isRecordingPaused = true
        timer?.invalidate()
        speech.pause()
        stopManualScriptScroll()
        updatePauseButton()
    }

    private func resumeRecording() {

        guard isRecording,
              isRecordingPaused
        else {
            return
        }

        recorder.resumeRecording()
        activeStartedAt = Date()
        isRecordingPaused = false
        startTimer()

        switch readMode {
        case .manual:
            startManualScriptScroll()

        case .auto:
            if speech.isPaused {
                speech.resume()
            } else {
                startAutoReadIfNeeded(
                    delayed: false
                )
            }
        }

        updatePauseButton()
    }

    private func handleRecordingFinished(
        _ result: Result<(URL, TimeInterval), Error>
    ) {

        isRecording = false
        isRecordingPaused = false
        timer?.invalidate()
        speech.stop()
        stopManualScriptScroll()
        updateRecordButton()
        updatePauseButton()

        switch result {
        case let .success((url, duration)):
            onFinishRecording?(
                url,
                duration
            )
            dismiss(
                animated: true
            )

        case let .failure(error):
            presentError(
                error.localizedDescription
            )
        }
    }

    private func updateRecordButton() {

        recordButton.setImage(
            UIImage(
                systemName:
                    isRecording
                    ? "stop.fill"
                    : "record.circle.fill"
            ),
            for: .normal
        )
    }

    private func updatePauseButton() {

        pauseButton.isHidden = !isRecording
        pauseButton.setImage(
            UIImage(
                systemName:
                    isRecordingPaused
                    ? "play.fill"
                    : "pause.fill"
            ),
            for: .normal
        )
        pauseButton.accessibilityLabel =
            isRecordingPaused
            ? L10n.recordResumeAccessibility
            : L10n.recordPauseAccessibility
    }

    private func startTimer() {

        timer?.invalidate()

        timer =
            Timer.scheduledTimer(
                withTimeInterval: 0.25,
                repeats: true
            ) {
                [weak self]
                _ in

                self?.updateTimer()
            }
    }

    private func updateTimer() {

        let elapsed =
            currentRecordingElapsed()

        timerLabel.text =
            Self.formatTime(
                elapsed
            )
    }

    private func currentRecordingElapsed() -> TimeInterval {

        guard let activeStartedAt else {
            return accumulatedRecordingTime
        }

        return accumulatedRecordingTime
        + Date().timeIntervalSince(
            activeStartedAt
        )
    }

    @objc
    private func onToggleRecord() {

        isRecording
        ? stopRecording()
        : startRecording()
    }

    @objc
    private func onTogglePause() {

        isRecordingPaused
        ? resumeRecording()
        : pauseRecording()
    }

    @objc
    private func onDone() {

        isRecording
        ? stopRecording()
        : dismiss(
            animated: true
        )
    }

    @objc
    private func onClose() {

        if isRecording {
            stopRecording()
        } else {
            dismiss(
                animated: true
            )
        }
    }

    @objc
    private func onSwitchCamera() {

        do {
            try recorder.switchCamera()
        } catch {
            presentError(
                error.localizedDescription
            )
        }
    }

    @objc
    private func onReadModeChanged() {

        readMode =
            ReadMode(
                rawValue: readModeControl.selectedSegmentIndex
            ) ?? .manual

        if isRecording,
           !isRecordingPaused {

            switch readMode {
            case .manual:
                speech.stop()
                resetScriptTextProgress()
                startManualScriptScroll()

            case .auto:
                stopManualScriptScroll()
                startAutoReadIfNeeded(
                    delayed: false
                )
            }
        }
    }

    private func setupSpeech() {

        speech.delegate = self
        speech.setText(
            script.content
        )
        speech.voice = selectedAppleVoice()
        speech.configuration.rate = 0.46
        speech.configuration.pitchMultiplier = 1.02
        speech.configuration.volume = 1.0
    }

    private func selectedAppleVoice() -> AVSpeechSynthesisVoice? {

        if let identifier =
            UserDefaults.standard.string(
                forKey: Self.selectedVoiceIdentifierKey
            ),
           let voice =
            SpeechManager.appleVoice(
                identifier: identifier
            ) {
            return voice
        }

        return SpeechManager
            .availableAppleVoices()
            .first {
                $0.language == "vi-VN"
            }
        ?? AVSpeechSynthesisVoice(
            language: "vi-VN"
        )
    }

    private func configureRecordingAudioSession() {

        try? AVAudioSession.sharedInstance().setCategory(
            .playAndRecord,
            mode: .videoRecording,
            options: [
                .defaultToSpeaker,
                .allowBluetooth,
                .mixWithOthers
            ]
        )

        try? AVAudioSession.sharedInstance().setActive(
            true
        )
    }

    private func startAutoReadIfNeeded(
        delayed: Bool
    ) {

        guard readMode == .auto else {
            return
        }

        guard !isRecordingPaused else {
            return
        }

        stopManualScriptScroll()
        configureRecordingAudioSession()
        resetScriptTextProgress()

        let speak = {
            [weak self] in

            guard let self,
                  isRecording,
                  !isRecordingPaused,
                  readMode == .auto
            else {
                return
            }

            speech.speak(
                from: 0
            )
        }

        if delayed {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.35,
                execute: speak
            )
        } else {
            speak()
        }
    }

    private func startManualScriptScroll() {

        stopManualScriptScroll()

        scriptTextView.layoutIfNeeded()
        scriptTextView.setContentOffset(
            .zero,
            animated: false
        )

        let displayLink =
            CADisplayLink(
                target: self,
                selector: #selector(onManualScrollTick)
            )

        displayLink.add(
            to: .main,
            forMode: .common
        )

        manualScrollDisplayLink = displayLink
        lastManualScrollTimestamp = nil
    }

    private func stopManualScriptScroll() {

        manualScrollDisplayLink?.invalidate()
        manualScrollDisplayLink = nil
        lastManualScrollTimestamp = nil
    }

    @objc
    private func onManualScrollTick(
        _ displayLink: CADisplayLink
    ) {

        guard isRecording,
              !isRecordingPaused,
              readMode == .manual
        else {
            stopManualScriptScroll()
            return
        }

        let maxOffset =
            max(
                0,
                scriptTextView.contentSize.height
                - scriptTextView.bounds.height
            )

        guard maxOffset > 0 else {
            return
        }

        let previousTimestamp =
            lastManualScrollTimestamp
            ?? displayLink.timestamp

        let deltaTime =
            displayLink.timestamp - previousTimestamp

        lastManualScrollTimestamp =
            displayLink.timestamp

        let words =
            max(
                1,
                script.content
                    .split {
                        $0.isWhitespace
                    }
                    .count
            )

        let estimatedDuration: CGFloat =
            max(
                12,
                CGFloat(words) / 100.0 * 60.0
            )

        let speed =
            maxOffset / estimatedDuration

        let nextOffset =
            min(
                maxOffset,
                scriptTextView.contentOffset.y
                + speed * CGFloat(deltaTime)
            )

        scriptTextView.setContentOffset(
            CGPoint(
                x: 0,
                y: nextOffset
            ),
            animated: false
        )
    }

    private func resetScriptTextProgress() {

        readEndUTF16 = 0
        currentReadRange = nil

        let text =
            script.content.isEmpty
            ? L10n.recordEmptyScript
            : script.content

        scriptTextView.attributedText =
            NSAttributedString(
                string: text,
                attributes: futureScriptAttributes
            )

        scriptTextView.setContentOffset(
            .zero,
            animated: false
        )
    }

    private func updateScriptHighlight(
        range: NSRange
    ) {

        let length =
            scriptTextView.textStorage.length

        guard length > 0 else {
            return
        }

        let clipped =
            range.clamped(
                toLength: length
            )

        guard clipped.length > 0 else {
            return
        }

        let storage =
            scriptTextView.textStorage

        storage.beginEditing()

        if let currentReadRange {

            storage.setAttributes(
                readScriptAttributes,
                range: currentReadRange.clamped(
                    toLength: length
                )
            )
        }

        if clipped.location > readEndUTF16 {

            storage.setAttributes(
                readScriptAttributes,
                range:
                    NSRange(
                        location: readEndUTF16,
                        length: clipped.location - readEndUTF16
                    ).clamped(
                        toLength: length
                    )
            )
        }

        storage.setAttributes(
            currentScriptAttributes,
            range: clipped
        )

        storage.endEditing()

        currentReadRange = clipped
        readEndUTF16 =
            max(
                readEndUTF16,
                clipped.location
            )

        scriptScrollController.updateTargetForCharacterRange(
            clipped
        )
    }

    private var paragraphStyle: NSParagraphStyle {

        let style =
            NSMutableParagraphStyle()

        style.lineSpacing = 5
        style.paragraphSpacing = 4

        return style
    }

    private var futureScriptAttributes: [NSAttributedString.Key: Any] {

        return [
            .foregroundColor:
                UIColor.white.withAlphaComponent(
                    0.58
                ),
            .font:
                scriptFont,
            .paragraphStyle:
                paragraphStyle
        ]
    }

    private var readScriptAttributes: [NSAttributedString.Key: Any] {

        return [
            .foregroundColor:
                UIColor.white.withAlphaComponent(
                    0.72
                ),
            .font:
                scriptFont,
            .paragraphStyle:
                paragraphStyle
        ]
    }

    private var currentScriptAttributes: [NSAttributedString.Key: Any] {

        return [
            .foregroundColor:
                UIColor.white,
            .font:
                scriptFont,
            .paragraphStyle:
                paragraphStyle
        ]
    }

    private func presentError(
        _ message: String
    ) {

        let alert =
            UIAlertController(
                title: L10n.recordVideoErrorTitle,
                message: message,
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

    private static func formatTime(
        _ time: TimeInterval
    ) -> String {

        let seconds =
            Int(time)

        return String(
            format: "%02d:%02d:%02d",
            seconds / 3600,
            (seconds % 3600) / 60,
            seconds % 60
        )
    }
}

extension RecordOverlayViewController: SpeechManagerDelegate {

    func speechManager(
        _ manager: SpeechManager,
        willSpeakCharacterRange range: NSRange,
        inFullText fullText: String
    ) {

        DispatchQueue.main.async {
            [weak self] in

            self?.updateScriptHighlight(
                range: range
            )
        }
    }

    func speechManagerDidFinish(
        _ manager: SpeechManager,
        completed: Bool
    ) {
    }
}

private extension NSRange {

    func clamped(
        toLength length: Int
    ) -> NSRange {

        let location =
            max(
                0,
                min(
                    self.location,
                    length
                )
            )

        let end =
            max(
                location,
                min(
                    self.location + self.length,
                    length
                )
            )

        return NSRange(
            location: location,
            length: end - location
        )
    }
}
