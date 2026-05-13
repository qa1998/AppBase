//
//  VideoTrimViewController.swift
//  AppBase
//

import AVFoundation
import AVKit
import SnapKit
import UIKit

final class VideoTrimViewController: UIViewController,
                                     UIScrollViewDelegate {

    var onSave: ((
        TimeInterval,
        TimeInterval,
        ScriptVideoAudioComposer.AudioMode,
        Float,
        Float
    ) -> Void)?

    private let asset: AVURLAsset
    private let speechAudioURL: URL?
    private let cleanupSpeechAudioOnDeinit: Bool
    private let hasSeparateScriptPreviewTrack: Bool
    private let initialAudioMode: ScriptVideoAudioComposer.AudioMode
    private let initialOriginalVolume: Float
    private let initialScriptVolume: Float
    private let playerItem: AVPlayerItem
    private let player: AVPlayer
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let previewView = UIView()
    private let timeLabel = UILabel()
    private let timelineContainer = UIView()
    private let videoTrimmer = VideoTrimmer()
    private let thumbnailScrollView = UIScrollView()
    private let thumbnailStack = UIStackView()
    private let waveformView = TimelineWaveformView()
    private let playheadView = UIView()
    private let toolbarStack = UIStackView()
    private let startSlider = UISlider()
    private let endSlider = UISlider()
    private let startLabel = UILabel()
    private let endLabel = UILabel()
    private let voiceStatusLabel = UILabel()
    private let audioModeLabel = UILabel()
    private let disableOriginalVoiceLabel = UILabel()
    private let disableOriginalVoiceSwitch = UISwitch()
    private let originalVolumeLabel = UILabel()
    private let originalVolumeSlider = UISlider()
    private let scriptVolumeLabel = UILabel()
    private let scriptVolumeSlider = UISlider()
    private let audioModeControl =
        UISegmentedControl(
            items: [
                "Voice gốc",
                "Voice script",
                "Gốc + script"
            ]
        )
    private let playButton = UIButton(type: .system)
    private let duration: TimeInterval
    private let minimumTrimDuration: TimeInterval = 0.5
    private var playerLayer: AVPlayerLayer?
    private var timeObserverToken: Any?
    private var currentTime: TimeInterval = 0
    private var previousOriginalVolume: Float = 1.0
    private var isSyncingTimelineScroll = false
    private var isScrubbingTimeline = false

    init(
        videoURL: URL,
        speechAudioURL: URL? = nil,
        cleanupSpeechAudioOnDeinit: Bool = false,
        initialAudioMode: ScriptVideoAudioComposer.AudioMode = .originalAndScript,
        initialOriginalVolume: Float = 1.0,
        initialScriptVolume: Float = 1.0
    ) {

        self.asset =
            AVURLAsset(
                url: videoURL
            )
        self.speechAudioURL = speechAudioURL
        self.cleanupSpeechAudioOnDeinit = cleanupSpeechAudioOnDeinit
        self.initialAudioMode = initialAudioMode
        self.initialOriginalVolume = initialOriginalVolume
        self.initialScriptVolume = initialScriptVolume
        self.playerItem =
            Self.makePreviewPlayerItem(
                videoAsset: self.asset,
                speechAudioURL: speechAudioURL
            )
        self.hasSeparateScriptPreviewTrack =
            Self.canUseSeparateScriptPreviewTrack(
                videoAsset: self.asset,
                speechAudioURL: speechAudioURL
            )
        self.player =
            AVPlayer(
                playerItem: self.playerItem
            )

        let seconds =
            CMTimeGetSeconds(
                asset.duration
            )

        self.duration =
            seconds.isFinite
            ? seconds
            : 0

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {

        fatalError(
            "init(coder:) has not been implemented"
        )
    }

    deinit {

        if let timeObserverToken {
            player.removeTimeObserver(
                timeObserverToken
            )
        }

        if cleanupSpeechAudioOnDeinit,
           let speechAudioURL {
            try? FileManager.default.removeItem(
                at: speechAudioURL
            )
        }
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        setupUI()
        setupNavigationItems()
        addPlaybackObserver()
        updateVolumeControlState()
        updateLabels()
        updateTimeLabel()
        applyPreviewAudioMix()
    }

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        playerLayer?.frame =
            previewView.bounds
    }

    override func viewWillDisappear(
        _ animated: Bool
    ) {

        super.viewWillDisappear(
            animated
        )

        player.pause()
    }

    private static func makePreviewPlayerItem(
        videoAsset: AVURLAsset,
        speechAudioURL: URL?
    ) -> AVPlayerItem {

        guard canUseSeparateScriptPreviewTrack(
            videoAsset: videoAsset,
            speechAudioURL: speechAudioURL
        ),
              let speechAudioURL,
              let videoTrack =
                videoAsset
                .tracks(
                    withMediaType: .video
                )
                .first
        else {
            return AVPlayerItem(
                asset: videoAsset
            )
        }

        let composition =
            AVMutableComposition()

        let fullVideoRange =
            CMTimeRange(
                start: .zero,
                duration: videoAsset.duration
            )

        do {
            guard let compositionVideoTrack =
                    composition.addMutableTrack(
                        withMediaType: .video,
                        preferredTrackID:
                            kCMPersistentTrackID_Invalid
                    )
            else {
                return AVPlayerItem(
                    asset: videoAsset
                )
            }

            try compositionVideoTrack.insertTimeRange(
                fullVideoRange,
                of: videoTrack,
                at: .zero
            )
            compositionVideoTrack.preferredTransform =
                videoTrack.preferredTransform

            try videoAsset
                .tracks(
                    withMediaType: .audio
                )
                .forEach {
                    sourceAudioTrack in

                    guard let compositionAudioTrack =
                            composition.addMutableTrack(
                                withMediaType: .audio,
                                preferredTrackID:
                                    kCMPersistentTrackID_Invalid
                            )
                    else {
                        return
                    }

                    try compositionAudioTrack.insertTimeRange(
                        fullVideoRange,
                        of: sourceAudioTrack,
                        at: .zero
                    )
                }

            let speechAsset =
                AVURLAsset(
                    url: speechAudioURL
                )

            if let speechTrack =
                speechAsset
                .tracks(
                    withMediaType: .audio
                )
                .first {

                let speechDuration =
                    CMTimeMinimum(
                        speechAsset.duration,
                        videoAsset.duration
                    )

                if speechDuration.seconds > 0,
                   let scriptAudioTrack =
                    composition.addMutableTrack(
                        withMediaType: .audio,
                        preferredTrackID:
                            kCMPersistentTrackID_Invalid
                    ) {

                    try scriptAudioTrack.insertTimeRange(
                        CMTimeRange(
                            start: .zero,
                            duration: speechDuration
                        ),
                        of: speechTrack,
                        at: .zero
                    )
                }
            }

            return AVPlayerItem(
                asset: composition
            )

        } catch {
            return AVPlayerItem(
                asset: videoAsset
            )
        }
    }

    private static func canUseSeparateScriptPreviewTrack(
        videoAsset: AVURLAsset,
        speechAudioURL: URL?
    ) -> Bool {

        guard let speechAudioURL else {
            return false
        }

        let speechAsset =
            AVURLAsset(
                url: speechAudioURL
            )

        return videoAsset
            .tracks(
                withMediaType: .video
            )
            .isEmpty == false
            && speechAsset
            .tracks(
                withMediaType: .audio
            )
            .isEmpty == false
    }

    private func setupUI() {

        title = "Trim video"
        view.backgroundColor = .black
        scrollView.backgroundColor = .black
        contentView.backgroundColor = .black

        previewView.backgroundColor = .black
        previewView.layer.cornerRadius = 4
        previewView.clipsToBounds = true

        let layer =
            AVPlayerLayer(
                player: player
            )

        layer.videoGravity = .resizeAspect
        previewView.layer.addSublayer(
            layer
        )
        playerLayer = layer

        playButton.setImage(
            UIImage(
                systemName: "play.fill"
            ),
            for: .normal
        )
        playButton.tintColor = .white
        playButton.backgroundColor =
            UIColor.white.withAlphaComponent(
                0.12
            )
        playButton.layer.cornerRadius = 26
        playButton.addTarget(
            self,
            action: #selector(onPlay),
            for: .touchUpInside
        )

        configureSlider(
            startSlider
        )
        configureSlider(
            endSlider
        )

        startSlider.value = 0
        endSlider.value =
            Float(
                duration
            )

        startSlider.addTarget(
            self,
            action: #selector(onStartChanged),
            for: .valueChanged
        )
        endSlider.addTarget(
            self,
            action: #selector(onEndChanged),
            for: .valueChanged
        )

        startLabel.font =
            .monospacedDigitSystemFont(
                ofSize: 14,
                weight: .medium
            )
        startLabel.textColor = .white
        endLabel.font =
            .monospacedDigitSystemFont(
                ofSize: 14,
                weight: .medium
            )
        endLabel.textColor = .white
        voiceStatusLabel.textColor =
            UIColor.white.withAlphaComponent(
                0.72
            )
        voiceStatusLabel.font =
            .systemFont(
                ofSize: 14,
                weight: .regular
            )
        voiceStatusLabel.text =
            asset
            .tracks(
                withMediaType: .audio
            )
            .isEmpty
            ? "Voice gốc: Không có"
            : "Voice gốc: Có"
        timeLabel.textColor =
            UIColor.white.withAlphaComponent(
                0.75
            )
        timeLabel.font =
            .monospacedDigitSystemFont(
                ofSize: 12,
                weight: .regular
            )
        timeLabel.text =
            "00:00 / \(Self.formatTime(duration))"
        setupTimeline()
        setupToolbar()
        audioModeLabel.text = "Audio sau khi lưu"
        audioModeLabel.font =
            .systemFont(
                ofSize: 15,
                weight: .semibold
            )
        audioModeLabel.textColor = .white
        audioModeControl.selectedSegmentIndex =
            Self.segmentIndex(
                for: initialAudioMode
            )
        audioModeControl.addTarget(
            self,
            action: #selector(onAudioModeChanged),
            for: .valueChanged
        )
        disableOriginalVoiceLabel.text = "Tắt voice gốc"
        disableOriginalVoiceLabel.font =
            .systemFont(
                ofSize: 15,
                weight: .medium
            )
        disableOriginalVoiceLabel.textColor = .white
        disableOriginalVoiceSwitch.addTarget(
            self,
            action: #selector(onDisableOriginalVoiceChanged),
            for: .valueChanged
        )

        let disableOriginalVoiceRow =
            UIStackView(
                arrangedSubviews: [
                    disableOriginalVoiceLabel,
                    disableOriginalVoiceSwitch
                ]
            )

        disableOriginalVoiceRow.axis = .horizontal
        disableOriginalVoiceRow.alignment = .center
        disableOriginalVoiceRow.distribution = .equalSpacing

        configureVolumeSlider(
            originalVolumeSlider
        )
        configureVolumeSlider(
            scriptVolumeSlider
        )

        originalVolumeSlider.value =
            initialOriginalVolume
        scriptVolumeSlider.value =
            initialScriptVolume

        originalVolumeSlider.addTarget(
            self,
            action: #selector(onVolumeChanged),
            for: .valueChanged
        )
        scriptVolumeSlider.addTarget(
            self,
            action: #selector(onVolumeChanged),
            for: .valueChanged
        )

        originalVolumeLabel.font =
            .systemFont(
                ofSize: 14,
                weight: .medium
            )
        originalVolumeLabel.textColor = .white
        scriptVolumeLabel.font =
            .systemFont(
                ofSize: 14,
                weight: .medium
            )
        scriptVolumeLabel.textColor = .white

        let stack =
            UIStackView()

        stack.axis = .vertical
        stack.spacing = 14

        view.addSubview(
            scrollView
        )
        scrollView.addSubview(
            contentView
        )
        contentView.addSubview(
            previewView
        )
        contentView.addSubview(
            playButton
        )
        contentView.addSubview(
            timeLabel
        )
        contentView.addSubview(
            timelineContainer
        )
        contentView.addSubview(
            stack
        )
        contentView.addSubview(
            toolbarStack
        )

        stack.addArrangedSubview(
            startLabel
        )
        stack.addArrangedSubview(
            startSlider
        )
        stack.addArrangedSubview(
            endLabel
        )
        stack.addArrangedSubview(
            endSlider
        )
        stack.addArrangedSubview(
            voiceStatusLabel
        )
        stack.addArrangedSubview(
            disableOriginalVoiceRow
        )
        stack.addArrangedSubview(
            audioModeLabel
        )
        stack.addArrangedSubview(
            audioModeControl
        )
        stack.addArrangedSubview(
            originalVolumeLabel
        )
        stack.addArrangedSubview(
            originalVolumeSlider
        )
        stack.addArrangedSubview(
            scriptVolumeLabel
        )
        stack.addArrangedSubview(
            scriptVolumeSlider
        )

        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive

        scrollView.snp.makeConstraints {
            $0.edges.equalTo(
                view.safeAreaLayoutGuide
            )
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(
                scrollView.contentLayoutGuide
            )
            $0.width.equalTo(
                scrollView.frameLayoutGuide
            )
        }

        previewView.snp.makeConstraints {
            $0.top.equalTo(
                contentView
            ).offset(20)
            $0.leading.trailing.equalTo(contentView)
                .inset(20)
            $0.height.equalTo(previewView.snp.width)
                .multipliedBy(9.0 / 16.0)
        }

        playButton.snp.makeConstraints {
            $0.top.equalTo(previewView.snp.bottom)
                .offset(12)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(52)
        }

        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(contentView)
                .offset(20)
            $0.top.equalTo(playButton.snp.bottom)
                .offset(6)
        }

        timelineContainer.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom)
                .offset(8)
            $0.leading.trailing.equalTo(contentView)
                .inset(14)
            $0.height.equalTo(118)
        }

        stack.snp.makeConstraints {
            $0.top.equalTo(timelineContainer.snp.bottom)
                .offset(20)
            $0.leading.trailing.equalTo(contentView)
                .inset(24)
        }

        toolbarStack.snp.makeConstraints {
            $0.top.equalTo(stack.snp.bottom)
                .offset(24)
            $0.leading.trailing.equalTo(contentView)
                .inset(8)
            $0.height.equalTo(68)
            $0.bottom.equalTo(contentView)
                .offset(-24)
        }
    }

    private func setupNavigationItems() {

        navigationItem.leftBarButtonItem =
            UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(onCancel)
            )

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(
                barButtonSystemItem: .save,
                target: self,
                action: #selector(onSaveTapped)
            )
    }

    private func setupTimeline() {

        timelineContainer.backgroundColor =
            UIColor.white.withAlphaComponent(
                0.06
            )
        timelineContainer.layer.cornerRadius = 12
        timelineContainer.clipsToBounds = true

        videoTrimmer.asset = asset
        videoTrimmer.minimumDuration =
            CMTime(
                seconds: minimumTrimDuration,
                preferredTimescale: 600
            )
        videoTrimmer.progressIndicatorMode = .alwaysShown
        videoTrimmer.trackBackgroundColor =
            UIColor.white.withAlphaComponent(
                0.12
            )
        videoTrimmer.thumbRestColor =
            UIColor.white.withAlphaComponent(
                0.08
            )
        videoTrimmer.addTarget(
            self,
            action: #selector(onTrimmerRangeChanged),
            for: VideoTrimmer.selectedRangeChanged
        )
        videoTrimmer.addTarget(
            self,
            action: #selector(onTrimmerScrubChanged),
            for: VideoTrimmer.progressChanged
        )
        videoTrimmer.addTarget(
            self,
            action: #selector(onTrimmerScrubBegan),
            for: VideoTrimmer.didBeginScrubbing
        )
        videoTrimmer.addTarget(
            self,
            action: #selector(onTrimmerScrubEnded),
            for: VideoTrimmer.didEndScrubbing
        )

        waveformView.backgroundColor = .clear

        playheadView.backgroundColor = .white
        playheadView.layer.cornerRadius = 1

        timelineContainer.addSubview(
            videoTrimmer
        )
        timelineContainer.addSubview(
            waveformView
        )

        videoTrimmer.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
                .inset(10)
            $0.height.equalTo(68)
        }

        waveformView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
                .inset(10)
            $0.top.equalTo(videoTrimmer.snp.bottom)
                .offset(8)
            $0.height.equalTo(28)
        }
    }

    private func setupToolbar() {

        toolbarStack.axis = .horizontal
        toolbarStack.alignment = .center
        toolbarStack.distribution = .fillEqually
        toolbarStack.spacing = 6
        toolbarStack.backgroundColor =
            UIColor.white.withAlphaComponent(
                0.08
            )
        toolbarStack.layer.cornerRadius = 14
        toolbarStack.isLayoutMarginsRelativeArrangement = true
        toolbarStack.layoutMargins =
            UIEdgeInsets(
                top: 8,
                left: 8,
                bottom: 8,
                right: 8
            )

        [
            ("wand.and.stars", "Effects"),
            ("camera.filters", "Filters"),
            ("square", "Format"),
            ("rectangle.dashed", "Canvas"),
            ("slider.horizontal.3", "Adjust")
        ].forEach {
            imageName,
            title in

            toolbarStack.addArrangedSubview(
                makeToolButton(
                    imageName: imageName,
                    title: title
                )
            )
        }
    }

    private func makeToolButton(
        imageName: String,
        title: String
    ) -> UIControl {

        let control =
            UIControl()

        let imageView =
            UIImageView(
                image:
                    UIImage(
                        systemName: imageName
                    )
            )

        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit

        let label =
            UILabel()

        label.text = title
        label.textColor =
            UIColor.white.withAlphaComponent(
                0.84
            )
        label.font =
            .systemFont(
                ofSize: 11,
                weight: .regular
            )
        label.textAlignment = .center

        let stack =
            UIStackView(
                arrangedSubviews: [
                    imageView,
                    label
                ]
            )

        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 5
        control.addSubview(
            stack
        )

        imageView.snp.makeConstraints {
            $0.width.height.equalTo(22)
        }

        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.lessThanOrEqualToSuperview()
        }

        return control
    }

    private func configureSlider(
        _ slider: UISlider
    ) {

        slider.minimumValue = 0
        slider.maximumValue =
            Float(
                max(
                    duration,
                    minimumTrimDuration
                )
            )
    }

    private func addPlaybackObserver() {

        timeObserverToken =
            player.addPeriodicTimeObserver(
                forInterval:
                    CMTime(
                        seconds: 0.05,
                        preferredTimescale: 600
                    ),
                queue: .main
            ) {
                [weak self]
                time in

                guard let self,
                      !isScrubbingTimeline
                else {
                    return
                }

                let seconds =
                    CMTimeGetSeconds(
                        time
                    )

                guard seconds.isFinite else {
                    return
                }

                currentTime =
                    min(
                        max(
                            0,
                            seconds
                        ),
                        duration
                    )

                if currentTime >= TimeInterval(endSlider.value) {
                    player.pause()
                    updatePlayButton()
                }

                updateTimeLabel()
                syncTimelineToCurrentTime()
            }
    }

    private func updateTimelineInsets() {

        let horizontalInset =
            max(
                0,
                thumbnailScrollView.bounds.width / 2 - 16
            )

        guard thumbnailScrollView.contentInset.left != horizontalInset else {
            return
        }

        thumbnailScrollView.contentInset =
            UIEdgeInsets(
                top: 0,
                left: horizontalInset,
                bottom: 0,
                right: horizontalInset
            )
        thumbnailScrollView.scrollIndicatorInsets =
            thumbnailScrollView.contentInset
        syncTimelineToCurrentTime()
    }

    private func syncTimelineToCurrentTime() {

        videoTrimmer.setProgress(
            CMTime(
                seconds: currentTime,
                preferredTimescale: 600
            ),
            animated: false
        )
    }

    private func timelineOffset(
        forProgress progress: CGFloat
    ) -> CGFloat {

        let leftInset =
            thumbnailScrollView.contentInset.left
        let rightInset =
            thumbnailScrollView.contentInset.right
        let scrollableWidth =
            max(
                1,
                thumbnailScrollView.contentSize.width
                - thumbnailScrollView.bounds.width
                + leftInset
                + rightInset
            )

        return -leftInset
        + scrollableWidth
        * min(
            1,
            max(
                0,
                progress
            )
        )
    }

    private func timelineProgressForCurrentOffset() -> CGFloat {

        let leftInset =
            thumbnailScrollView.contentInset.left
        let rightInset =
            thumbnailScrollView.contentInset.right
        let scrollableWidth =
            max(
                1,
                thumbnailScrollView.contentSize.width
                - thumbnailScrollView.bounds.width
                + leftInset
                + rightInset
            )

        return min(
            1,
            max(
                0,
                (
                    thumbnailScrollView.contentOffset.x
                    + leftInset
                )
                / scrollableWidth
            )
        )
    }

    private func scrubTimelineToCurrentOffset() {

        guard !isSyncingTimelineScroll else {
            return
        }

        currentTime =
            duration
            * TimeInterval(
                timelineProgressForCurrentOffset()
            )

        player.pause()
        updatePlayButton()
        updateTimeLabel()
        seekPreview(
            to: currentTime
        )
    }

    private func generateTimelineThumbnails() {

        let thumbnailCount = 8
        let generator =
            AVAssetImageGenerator(
                asset: asset
            )

        generator.appliesPreferredTrackTransform = true
        generator.maximumSize =
            CGSize(
                width: 140,
                height: 140
            )

        let duration =
            max(
                self.duration,
                1
            )

        let times =
            (0..<thumbnailCount).map {
                index in

                NSValue(
                    time:
                        CMTime(
                            seconds:
                                duration
                                * Double(index)
                                / Double(thumbnailCount),
                            preferredTimescale: 600
                        )
                )
            }

        for _ in 0..<thumbnailCount {
            let placeholder =
                makeThumbnailView()

            thumbnailStack.addArrangedSubview(
                placeholder
            )
        }

        generator.generateCGImagesAsynchronously(
            forTimes: times
        ) {
            [weak self]
            _,
            image,
            _,
            _,
            _ in

            guard let self,
                  let image
            else {
                return
            }

            DispatchQueue.main.async {
                guard let imageView =
                        self.thumbnailStack
                        .arrangedSubviews
                        .compactMap({
                            $0 as? UIImageView
                        })
                        .first(where: {
                            $0.image == nil
                        })
                else {
                    return
                }

                imageView.image =
                    UIImage(
                        cgImage: image
                    )
            }
        }
    }

    private func makeThumbnailView() -> UIImageView {

        let imageView =
            UIImageView()

        imageView.backgroundColor =
            UIColor.white.withAlphaComponent(
                0.12
            )
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4

        imageView.snp.makeConstraints {
            $0.width.equalTo(64)
        }

        return imageView
    }

    private func configureVolumeSlider(
        _ slider: UISlider
    ) {

        slider.minimumValue = 0
        slider.maximumValue = 2
        slider.value = 1
    }

    @objc
    private func onTrimmerRangeChanged() {

        let selectedRange =
            videoTrimmer.selectedRange

        let start =
            CMTimeGetSeconds(
                selectedRange.start
            )
        let end =
            CMTimeGetSeconds(
                selectedRange.end
            )

        guard start.isFinite,
              end.isFinite
        else {
            return
        }

        startSlider.value =
            Float(
                start
            )
        endSlider.value =
            Float(
                end
            )

        updateLabels()
    }

    @objc
    private func onTrimmerScrubBegan() {

        isScrubbingTimeline = true
        player.pause()
        updatePlayButton()
    }

    @objc
    private func onTrimmerScrubChanged() {

        let seconds =
            CMTimeGetSeconds(
                videoTrimmer.progress
            )

        guard seconds.isFinite else {
            return
        }

        currentTime =
            min(
                max(
                    0,
                    seconds
                ),
                duration
            )

        seekPreview(
            to: currentTime
        )
        updateTimeLabel()
    }

    @objc
    private func onTrimmerScrubEnded() {

        isScrubbingTimeline = false
    }

    func scrollViewWillBeginDragging(
        _ scrollView: UIScrollView
    ) {

        guard scrollView === thumbnailScrollView else {
            return
        }

        isScrubbingTimeline = true
        player.pause()
        updatePlayButton()
    }

    func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {

        guard scrollView === thumbnailScrollView else {
            return
        }

        scrubTimelineToCurrentOffset()
    }

    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {

        guard scrollView === thumbnailScrollView,
              !decelerate
        else {
            return
        }

        isScrubbingTimeline = false
    }

    func scrollViewDidEndDecelerating(
        _ scrollView: UIScrollView
    ) {

        guard scrollView === thumbnailScrollView else {
            return
        }

        isScrubbingTimeline = false
    }

    @objc
    private func onPlay() {

        if player.timeControlStatus == .playing {
            player.pause()
            updatePlayButton()
            return
        }

        let playStart =
            min(
                max(
                    currentTime,
                    TimeInterval(startSlider.value)
                ),
                TimeInterval(endSlider.value)
            )

        currentTime = playStart
        updateTimeLabel()
        player.seek(
            to:
                CMTime(
                    seconds: playStart,
                    preferredTimescale: 600
                ),
            toleranceBefore: .zero,
            toleranceAfter: .zero
        ) {
            [weak self]
            _ in

            self?.player.play()
            self?.updatePlayButton()
        }
    }

    @objc
    private func onStartChanged() {

        let maxStart =
            max(
                0,
                TimeInterval(endSlider.value) - minimumTrimDuration
            )

        startSlider.value =
            Float(
                min(
                    TimeInterval(startSlider.value),
                    maxStart
                )
            )

        seekPreview(
            to: TimeInterval(
                startSlider.value
            )
        )
        currentTime =
            TimeInterval(
                startSlider.value
            )
        updateTimeLabel()
        syncTimelineToCurrentTime()
        syncTrimmerRangeFromSliders()
        updateLabels()
    }

    @objc
    private func onEndChanged() {

        let minEnd =
            min(
                duration,
                TimeInterval(startSlider.value) + minimumTrimDuration
            )

        endSlider.value =
            Float(
                max(
                    TimeInterval(endSlider.value),
                    minEnd
                )
            )

        seekPreview(
            to: TimeInterval(
                endSlider.value
            )
        )
        currentTime =
            TimeInterval(
                endSlider.value
            )
        updateTimeLabel()
        syncTimelineToCurrentTime()
        syncTrimmerRangeFromSliders()
        updateLabels()
    }

    private func syncTrimmerRangeFromSliders() {

        videoTrimmer.selectedRange =
            CMTimeRange(
                start:
                    CMTime(
                        seconds: TimeInterval(startSlider.value),
                        preferredTimescale: 600
                    ),
                end:
                    CMTime(
                        seconds: TimeInterval(endSlider.value),
                        preferredTimescale: 600
                    )
            )
    }

    @objc
    private func onDisableOriginalVoiceChanged() {

        if disableOriginalVoiceSwitch.isOn {
            previousOriginalVolume =
                originalVolumeSlider.value
            originalVolumeSlider.value = 0
            audioModeControl.selectedSegmentIndex = 1
        } else {
            originalVolumeSlider.value =
                previousOriginalVolume > 0
                ? previousOriginalVolume
                : 1
        }

        audioModeControl.isEnabled =
            !disableOriginalVoiceSwitch.isOn
        audioModeControl.alpha =
            disableOriginalVoiceSwitch.isOn
            ? 0.45
            : 1

        updateVolumeControlState()
        updateLabels()
        applyPreviewAudioMix()
    }

    @objc
    private func onAudioModeChanged() {

        updateVolumeControlState()
        updateLabels()
        applyPreviewAudioMix()
    }

    @objc
    private func onVolumeChanged() {

        updateLabels()
        applyPreviewAudioMix()
    }

    private func seekPreview(
        to seconds: TimeInterval
    ) {

        player.pause()
        player.seek(
            to:
                CMTime(
                    seconds: seconds,
                    preferredTimescale: 600
                ),
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
    }

    private func updateTimeLabel() {

        timeLabel.text =
            "\(Self.formatTime(currentTime)) / \(Self.formatTime(duration))"
    }

    private func updatePlayButton() {

        playButton.setImage(
            UIImage(
                systemName:
                    player.timeControlStatus == .playing
                    ? "pause.fill"
                    : "play.fill"
            ),
            for: .normal
        )
    }

    private func applyPreviewAudioMix() {

        let audioTracks =
            playerItem
            .asset
            .tracks(
                withMediaType: .audio
            )

        guard !audioTracks.isEmpty else {
            playerItem.audioMix = nil
            return
        }

        let mode =
            selectedAudioMode()
        let originalVolume =
            selectedOriginalVolume()
        let scriptVolume =
            selectedScriptVolume()

        let parameters =
            audioTracks
            .enumerated()
            .map {
                index,
                track in

                let input =
                    AVMutableAudioMixInputParameters(
                        track: track
                    )

                input.setVolume(
                    previewVolume(
                        forTrackAt: index,
                        totalTracks: audioTracks.count,
                        mode: mode,
                        originalVolume: originalVolume,
                        scriptVolume: scriptVolume,
                        hasSeparateScriptTrack:
                            hasSeparateScriptPreviewTrack
                    ),
                    at: .zero
                )

                return input
            }

        let mix =
            AVMutableAudioMix()

        mix.inputParameters =
            parameters
        playerItem.audioMix =
            mix
    }

    private func previewVolume(
        forTrackAt index: Int,
        totalTracks: Int,
        mode: ScriptVideoAudioComposer.AudioMode,
        originalVolume: Float,
        scriptVolume: Float,
        hasSeparateScriptTrack: Bool
    ) -> Float {

        switch mode {
        case .originalOnly:
            return originalTrackVolume(
                index: index,
                totalTracks: totalTracks,
                originalVolume: originalVolume,
                hasSeparateScriptTrack:
                    hasSeparateScriptTrack
            )

        case .scriptOnly:
            return scriptTrackVolume(
                index: index,
                totalTracks: totalTracks,
                scriptVolume: scriptVolume,
                hasSeparateScriptTrack:
                    hasSeparateScriptTrack
            )

        case .originalAndScript:
            return hasSeparateScriptTrack
            && index == totalTracks - 1
            ? scriptVolume
            : originalVolume
        }
    }

    private func originalTrackVolume(
        index: Int,
        totalTracks: Int,
        originalVolume: Float,
        hasSeparateScriptTrack: Bool
    ) -> Float {

        return hasSeparateScriptTrack
        && index == totalTracks - 1
        ? 0
        : originalVolume
    }

    private func scriptTrackVolume(
        index: Int,
        totalTracks: Int,
        scriptVolume: Float,
        hasSeparateScriptTrack: Bool
    ) -> Float {

        guard hasSeparateScriptTrack else {
            // Old videos may have a single mixed audio track, so there is no
            // separate script track to solo in preview.
            return scriptVolume
        }

        return index == totalTracks - 1
        ? scriptVolume
        : 0
    }

    private func updateLabels() {

        startLabel.text =
            "Bắt đầu: \(Self.formatTime(TimeInterval(startSlider.value)))"
        endLabel.text =
            "Kết thúc: \(Self.formatTime(TimeInterval(endSlider.value)))"
        originalVolumeLabel.text =
            "Âm voice gốc: \(Self.formatPercent(originalVolumeSlider.value))"
        scriptVolumeLabel.text =
            "Âm voice script: \(Self.formatPercent(scriptVolumeSlider.value))"
    }

    @objc
    private func onCancel() {

        dismiss(
            animated: true
        )
    }

    @objc
    private func onSaveTapped() {

        onSave?(
            TimeInterval(startSlider.value),
            TimeInterval(endSlider.value),
            selectedAudioMode(),
            selectedOriginalVolume(),
            selectedScriptVolume()
        )

        dismiss(
            animated: true
        )
    }

    private static func formatTime(
        _ time: TimeInterval
    ) -> String {

        let seconds =
            Int(
                time.rounded()
            )

        return String(
            format: "%02d:%02d",
            seconds / 60,
            seconds % 60
        )
    }

    private static func formatPercent(
        _ value: Float
    ) -> String {

        String(
            format: "%.0f%%",
            value * 100
        )
    }

    private static func segmentIndex(
        for mode: ScriptVideoAudioComposer.AudioMode
    ) -> Int {

        switch mode {
        case .originalOnly:
            return 0

        case .scriptOnly:
            return 1

        case .originalAndScript:
            return 2
        }
    }

    private func updateVolumeControlState() {

        let mode =
            selectedAudioMode()

        let usesOriginal =
            mode == .originalOnly
            || mode == .originalAndScript

        let usesScript =
            mode == .scriptOnly
            || mode == .originalAndScript

        originalVolumeSlider.isEnabled = usesOriginal
        originalVolumeSlider.alpha =
            usesOriginal
            ? 1
            : 0.45

        scriptVolumeSlider.isEnabled = usesScript
        scriptVolumeSlider.alpha =
            usesScript
            ? 1
            : 0.45
    }

    private func selectedAudioMode() -> ScriptVideoAudioComposer.AudioMode {

        if disableOriginalVoiceSwitch.isOn {
            return .scriptOnly
        }

        switch audioModeControl.selectedSegmentIndex {
        case 1:
            return .scriptOnly

        case 2:
            return .originalAndScript

        default:
            return .originalOnly
        }
    }

    private func selectedOriginalVolume() -> Float {

        disableOriginalVoiceSwitch.isOn
        ? 0
        : originalVolumeSlider.value
    }

    private func selectedScriptVolume() -> Float {

        scriptVolumeSlider.value
    }
}

private final class TimelineWaveformView: UIView {

    override func draw(
        _ rect: CGRect
    ) {

        guard let context =
                UIGraphicsGetCurrentContext()
        else {
            return
        }

        context.setFillColor(
            UIColor.systemTeal.cgColor
        )

        let barWidth: CGFloat = 3
        let gap: CGFloat = 2
        let step =
            barWidth + gap
        let count =
            Int(
                rect.width / step
            )

        for index in 0..<count {
            let progress =
                CGFloat(index)
                / CGFloat(
                    max(
                        1,
                        count - 1
                    )
                )
            let wave =
                abs(
                    sin(
                        progress * .pi * 7
                    )
                )
            let height =
                max(
                    4,
                    rect.height
                    * (
                        0.28
                        + wave * 0.72
                    )
                )
            let x =
                CGFloat(index) * step
            let y =
                rect.midY - height / 2

            context.fill(
                CGRect(
                    x: x,
                    y: y,
                    width: barWidth,
                    height: height
                )
            )
        }
    }
}
