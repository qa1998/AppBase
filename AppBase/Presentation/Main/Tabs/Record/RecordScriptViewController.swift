//
//  RecordScriptViewController.swift
//  AppBase
//

import SnapKit
import UIKit
import BaseMVVM
import AVFoundation
import AVKit
import PhotosUI
import UniformTypeIdentifiers

final class RecordScriptViewController: TIOViewController<RecordScriptViewModel>,
                                        UITableViewDataSource,
                                        UITableViewDelegate,
                                        PHPickerViewControllerDelegate {

    private let tableView = UITableView(
        frame: .zero,
        style: .insetGrouped
    )

    private let recordButton =
        UIButton(type: .system)

    private var processingTitle =
        L10n.recordProcessingVoice

    init(
        script: TeleprompterScript
    ) {

        super.init(
            nibName: nil,
            bundle: nil
        )

        invoke(
            viewModel:
                RecordScriptViewModel(
                    script: script
                )
        )
    }

    required init?(coder: NSCoder) {

        fatalError(
            "init(coder:) has not been implemented"
        )
    }

    override func setupUI() {

        super.setupUI()

        view.backgroundColor = .systemBackground
        title = viewModel.script.title.isEmpty
        ? "Record"
        : viewModel.script.title

        setupNavigationItems()
        setupTableView()
        setupRecordButton()
    }

    override func onBind() {

        super.onBind()

        viewModel.onRecordingsChanged = {
            [weak self] in

            self?.tableView.reloadData()
        }

        viewModel.onProcessingChanged = {
            [weak self]
            isProcessing in

            self?.updateProcessingState(
                isProcessing
            )
        }

        viewModel.onError = {
            [weak self]
            message in

            self?.presentError(
                message
            )
        }
    }

    override func viewWillDisappear(
        _ animated: Bool
    ) {

        super.viewWillDisappear(
            animated
        )

        // Video capture runs in the full-screen overlay, so no active work lives here.
    }

    private func setupTableView() {

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemBackground
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "recordingCell"
        )

        view.addSubview(
            tableView
        )

        tableView.snp.makeConstraints {

            $0.top.leading.trailing.equalTo(
                view.safeAreaLayoutGuide
            )

            $0.bottom.equalToSuperview()
                .offset(-104)
        }

        tableView.tableHeaderView =
            makeHeaderView()
    }

    private func setupNavigationItems() {

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(
                image:
                    UIImage(
                        systemName: "square.and.arrow.down"
                    ),
                style: .plain,
                target: self,
                action: #selector(onImportVideo)
            )

        navigationItem.rightBarButtonItem?.accessibilityLabel =
            L10n.recordImportVideoAction
    }

    private func setupRecordButton() {

        recordButton.backgroundColor = .systemRed
        recordButton.tintColor = .white
        recordButton.layer.cornerRadius = 28
        recordButton.titleLabel?.font =
            .systemFont(
                ofSize: 17,
                weight: .semibold
            )
        recordButton.setImage(
            UIImage(
                systemName: "video.fill"
            ),
            for: .normal
        )
        recordButton.setTitle(
            "  \(L10n.recordVideoAction)",
            for: .normal
        )
        recordButton.addTarget(
            self,
            action: #selector(onOpenRecordOverlay),
            for: .touchUpInside
        )

        view.addSubview(
            recordButton
        )

        recordButton.snp.makeConstraints {

            $0.leading.trailing.equalToSuperview()
                .inset(20)

            $0.bottom.equalTo(
                view.safeAreaLayoutGuide.snp.bottom
            ).offset(-16)

            $0.height.equalTo(56)
        }
    }

    private func updateProcessingState(
        _ isProcessing: Bool
    ) {

        recordButton.isEnabled = !isProcessing
        navigationItem.rightBarButtonItem?.isEnabled =
            !isProcessing
        recordButton.alpha =
            isProcessing
            ? 0.65
            : 1
        recordButton.setTitle(
            isProcessing
            ? "  \(processingTitle)"
            : "  \(L10n.recordVideoAction)",
            for: .normal
        )
    }

    private func makeHeaderView() -> UIView {

        let width =
            UIScreen.main.bounds.width

        let container =
            UIView(
                frame:
                    CGRect(
                        x: 0,
                        y: 0,
                        width: width,
                        height: 1
                    )
            )

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10

        let titleLabel = UILabel()
        titleLabel.text =
            viewModel.script.title.isEmpty
            ? "Không tiêu đề"
            : viewModel.script.title
        titleLabel.font =
            .systemFont(
                ofSize: 24,
                weight: .bold
            )
        titleLabel.numberOfLines = 0

        let bodyLabel = UILabel()
        bodyLabel.text =
            viewModel.script.content.isEmpty
            ? "(Chưa có nội dung)"
            : viewModel.script.content
        bodyLabel.font =
            .systemFont(
                ofSize: 17,
                weight: .regular
            )
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 0

        let sectionLabel = UILabel()
        sectionLabel.text = "Video đã quay"
        sectionLabel.font =
            .systemFont(
                ofSize: 18,
                weight: .semibold
            )

        container.addSubview(
            stack
        )

        stack.addArrangedSubview(
            titleLabel
        )
        stack.addArrangedSubview(
            bodyLabel
        )
        stack.addArrangedSubview(
            sectionLabel
        )

        stack.snp.makeConstraints {

            $0.edges.equalToSuperview()
                .inset(20)
        }

        container.layoutIfNeeded()

        let targetSize =
            CGSize(
                width: width,
                height: UIView.layoutFittingCompressedSize.height
            )

        let height =
            container.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            ).height

        container.frame.size.height =
            height

        return container
    }

    @objc
    private func onOpenRecordOverlay() {

        do {

            let outputURL =
                try viewModel.makeVideoOutputURL()

            let vc =
                RecordOverlayViewController(
                    script: viewModel.script,
                    outputURL: outputURL
                )

            vc.onFinishRecording = {
                [weak self]
                fileURL,
                duration in

                self?.processingTitle =
                    L10n.recordProcessingVoice

                self?.viewModel.saveVideoRecording(
                    fileURL: fileURL,
                    duration: duration
                )
            }

            present(
                vc,
                animated: true
            )

        } catch {

            presentError(
                error.localizedDescription
            )
        }
    }

    @objc
    private func onImportVideo() {

        var configuration =
            PHPickerConfiguration(
                photoLibrary: .shared()
            )

        configuration.filter = .videos
        configuration.selectionLimit = 1
        configuration.preferredAssetRepresentationMode =
            .current

        let picker =
            PHPickerViewController(
                configuration: configuration
            )

        picker.delegate = self

        present(
            picker,
            animated: true
        )
    }

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {

        picker.dismiss(
            animated: true
        )

        guard let provider =
                results.first?.itemProvider,
              provider.hasItemConformingToTypeIdentifier(
                UTType.movie.identifier
              )
        else {
            return
        }

        processingTitle =
            L10n.recordImportProcessing

        provider.loadFileRepresentation(
            forTypeIdentifier: UTType.movie.identifier
        ) {
            [weak self]
            url,
            error in

            guard let self else {
                return
            }

            if let error {
                DispatchQueue.main.async {
                    self.presentError(
                        error.localizedDescription
                    )
                }
                return
            }

            guard let url else {
                DispatchQueue.main.async {
                    self.presentError(
                        L10n.recordImportVideoError
                    )
                }
                return
            }

            do {
                let temporaryURL =
                    try self.copyPickedVideoToTemporaryURL(
                        url
                    )

                DispatchQueue.main.async {
                    self.viewModel.importVideo(
                        from: temporaryURL
                    )

                    try? FileManager.default.removeItem(
                        at: temporaryURL
                    )
                }

            } catch {
                DispatchQueue.main.async {
                    self.presentError(
                        error.localizedDescription
                    )
                }
            }
        }
    }

    private func copyPickedVideoToTemporaryURL(
        _ sourceURL: URL
    ) throws -> URL {

        let fileExtension =
            sourceURL.pathExtension.isEmpty
            ? "mov"
            : sourceURL.pathExtension

        let temporaryURL =
            FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "\(UUID().uuidString).\(fileExtension)"
            )

        try FileManager.default.copyItem(
            at: sourceURL,
            to: temporaryURL
        )

        return temporaryURL
    }

    private func presentError(
        _ message: String
    ) {

        let alert =
            UIAlertController(
                title: "Không thể quay video",
                message: message,
                preferredStyle: .alert
            )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )

        present(
            alert,
            animated: true
        )
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        viewModel.recordings.count
    }

    func tableView(
        _ tableView: UITableView,
        titleForFooterInSection section: Int
    ) -> String? {

        viewModel.recordings.isEmpty
        ? "Chưa có video nào cho script này."
        : nil
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "recordingCell",
                for: indexPath
            )

        guard let recording =
            viewModel.recording(
                at: indexPath.row
            )
        else {
            return cell
        }

        var config =
            cell.defaultContentConfiguration()

        config.image =
            UIImage(
                systemName: "play.rectangle.fill"
            )

        config.text =
            "Video \(indexPath.row + 1)"

        config.secondaryText =
            "\(Self.formatDate(recording.createdAt)) · \(Self.formatDuration(recording.duration))"

        cell.contentConfiguration = config
        cell.accessoryType = .none

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        guard let recording =
            viewModel.recording(
                at: indexPath.row
            )
        else {
            return
        }

        playVideo(
            recording: recording
        )
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        guard let recording =
            viewModel.recording(
                at: indexPath.row
            )
        else {
            return nil
        }

        let delete =
            UIContextualAction(
                style: .destructive,
                title: "Xóa"
            ) {
                [weak self]
                _,
                _,
                completion in

                self?.viewModel.deleteRecording(
                    recording
                )

                completion(true)
            }

        let share =
            UIContextualAction(
                style: .normal,
                title: "Chia sẻ"
            ) {
                [weak self]
                _,
                _,
                completion in

                self?.shareRecording(
                    recording
                )

                completion(true)
            }

        share.backgroundColor = .systemBlue

        let edit =
            UIContextualAction(
                style: .normal,
                title: "Sửa"
            ) {
                [weak self]
                _,
                _,
                completion in

                self?.openTrimEditor(
                    recording: recording
                )

                completion(true)
            }

        edit.backgroundColor = .systemOrange

        return UISwipeActionsConfiguration(
            actions: [
                delete,
                edit,
                share
            ]
        )
    }

    private func openTrimEditor(
        recording: ScriptRecording
    ) {

        processingTitle =
            L10n.recordTrimProcessing

        let videoURL =
            viewModel.fileURL(
                for: recording
            )

        viewModel.prepareTrimSpeechAudio(
            for: recording,
            baseURL: videoURL
        ) {
            [weak self]
            speechAudioURL,
            shouldCleanupSpeechAudio in

            self?.presentTrimEditor(
                recording: recording,
                videoURL: videoURL,
                speechAudioURL: speechAudioURL,
                shouldCleanupSpeechAudio:
                    shouldCleanupSpeechAudio
            )
        }
    }

    private func presentTrimEditor(
        recording: ScriptRecording,
        videoURL: URL,
        speechAudioURL: URL?,
        shouldCleanupSpeechAudio: Bool
    ) {

        let vc =
            VideoTrimViewController(
                videoURL: videoURL,
                speechAudioURL: speechAudioURL,
                cleanupSpeechAudioOnDeinit:
                    shouldCleanupSpeechAudio,
                initialAudioMode:
                    viewModel.audioMode(
                        for: recording
                    ),
                initialOriginalVolume:
                    viewModel.originalVolume(
                        for: recording
                    ),
                initialScriptVolume:
                    viewModel.scriptVolume(
                        for: recording
                    )
            )

        vc.onSave = {
            [weak self]
            startTime,
            endTime,
            audioMode,
            originalVolume,
            scriptVolume in

            self?.viewModel.trimRecording(
                recording,
                startTime: startTime,
                endTime: endTime,
                audioMode: audioMode,
                originalVolume: originalVolume,
                scriptVolume: scriptVolume
            )
        }

        let navigationController =
            UINavigationController(
                rootViewController: vc
            )

        present(
            navigationController,
            animated: true
        )
    }

    private func shareRecording(
        _ recording: ScriptRecording
    ) {

        let vc =
            UIActivityViewController(
                activityItems: [
                    viewModel.fileURL(
                        for: recording
                    )
                ],
                applicationActivities: nil
            )

        present(
            vc,
            animated: true
        )
    }

    private func playVideo(
        recording: ScriptRecording
    ) {

        let videoURL =
            viewModel.fileURL(
                for: recording
            )

        let player =
            AVPlayer(
                playerItem:
                    makePlaybackItem(
                        recording: recording,
                        videoURL: videoURL
                    )
            )

        let vc =
            AVPlayerViewController()

        vc.player = player

        present(
            vc,
            animated: true
        ) {
            player.play()
        }
    }

    private func makePlaybackItem(
        recording: ScriptRecording,
        videoURL: URL
    ) -> AVPlayerItem {

        let videoAsset =
            AVURLAsset(
                url: videoURL
            )

        guard let scriptAudioURL =
                viewModel.scriptAudioURL(
                    for: recording
                ),
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

        do {
            let fullRange =
                CMTimeRange(
                    start: .zero,
                    duration: videoAsset.duration
                )

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
                fullRange,
                of: videoTrack,
                at: .zero
            )
            compositionVideoTrack.preferredTransform =
                videoTrack.preferredTransform

            var audioTracks: [AVMutableCompositionTrack] = []

            try videoAsset
                .tracks(
                    withMediaType: .audio
                )
                .forEach {
                    sourceAudioTrack in

                    guard let track =
                            composition.addMutableTrack(
                                withMediaType: .audio,
                                preferredTrackID:
                                    kCMPersistentTrackID_Invalid
                            )
                    else {
                        return
                    }

                    try track.insertTimeRange(
                        fullRange,
                        of: sourceAudioTrack,
                        at: .zero
                    )
                    audioTracks.append(
                        track
                    )
                }

            let scriptAsset =
                AVURLAsset(
                    url: scriptAudioURL
                )

            if let scriptAudioTrack =
                scriptAsset
                .tracks(
                    withMediaType: .audio
                )
                .first,
               let track =
                composition.addMutableTrack(
                    withMediaType: .audio,
                    preferredTrackID:
                        kCMPersistentTrackID_Invalid
                ) {

                try track.insertTimeRange(
                    CMTimeRange(
                        start: .zero,
                        duration:
                            CMTimeMinimum(
                                scriptAsset.duration,
                                videoAsset.duration
                            )
                    ),
                    of: scriptAudioTrack,
                    at: .zero
                )
                audioTracks.append(
                    track
                )
            }

            let item =
                AVPlayerItem(
                    asset: composition
                )

            item.audioMix =
                makePlaybackAudioMix(
                    tracks: audioTracks,
                    recording: recording
                )

            return item

        } catch {
            return AVPlayerItem(
                asset: videoAsset
            )
        }
    }

    private func makePlaybackAudioMix(
        tracks: [AVCompositionTrack],
        recording: ScriptRecording
    ) -> AVAudioMix? {

        guard !tracks.isEmpty else {
            return nil
        }

        let mode =
            viewModel.audioMode(
                for: recording
            )
        let originalVolume =
            viewModel.originalVolume(
                for: recording
            )
        let scriptVolume =
            viewModel.scriptVolume(
                for: recording
            )
        let scriptTrackIndex =
            tracks.count - 1

        let mix =
            AVMutableAudioMix()

        mix.inputParameters =
            tracks
            .enumerated()
            .map {
                index,
                track in

                let parameters =
                    AVMutableAudioMixInputParameters(
                        track: track
                    )

                let volume: Float

                switch mode {
                case .originalOnly:
                    volume =
                        index == scriptTrackIndex
                        ? 0
                        : originalVolume

                case .scriptOnly:
                    volume =
                        index == scriptTrackIndex
                        ? scriptVolume
                        : 0

                case .originalAndScript:
                    volume =
                        index == scriptTrackIndex
                        ? scriptVolume
                        : originalVolume
                }

                parameters.setVolume(
                    volume,
                    at: .zero
                )

                return parameters
            }

        return mix
    }

    private static func formatDate(
        _ date: Date
    ) -> String {

        let formatter =
            DateFormatter()

        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale =
            Locale(
                identifier: "vi_VN"
            )

        return formatter.string(
            from: date
        )
    }

    private static func formatDuration(
        _ duration: TimeInterval
    ) -> String {

        let seconds =
            Int(
                duration.rounded()
            )

        return String(
            format: "%02d:%02d",
            seconds / 60,
            seconds % 60
        )
    }
}
