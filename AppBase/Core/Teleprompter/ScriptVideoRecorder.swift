//
//  ScriptVideoRecorder.swift
//  AppBase
//

import AVFoundation
import UIKit

final class ScriptVideoRecorder: NSObject {

    enum RecorderError: LocalizedError {
        case cameraDenied
        case microphoneDenied
        case cameraUnavailable
        case outputUnavailable

        var errorDescription: String? {
            switch self {
            case .cameraDenied:
                return "Ứng dụng chưa được cấp quyền camera."
            case .microphoneDenied:
                return "Ứng dụng chưa được cấp quyền microphone."
            case .cameraUnavailable:
                return "Không thể khởi tạo camera."
            case .outputUnavailable:
                return "Không thể khởi tạo bộ quay video."
            }
        }
    }

    private let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var currentCameraPosition: AVCaptureDevice.Position = .front
    private var finishHandler: ((Result<(URL, TimeInterval), Error>) -> Void)?
    private var outputURL: URL?
    private var currentSegmentURL: URL?
    private var currentSegmentStartedAt: Date?
    private var segmentURLs: [URL] = []
    private var accumulatedDuration: TimeInterval = 0
    private var isRecordingSession = false
    private var isStoppingForPause = false
    private var isFinishingRecording = false
    private var shouldResumeAfterPauseStop = false
    private(set) var isRecordingPaused = false
    private(set) var isConfigured = false

    var isRecording: Bool {
        isRecordingSession
    }

    func requestPermissions(
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

        AVCaptureDevice.requestAccess(
            for: .video
        ) {
            cameraGranted in

            guard cameraGranted else {
                DispatchQueue.main.async {
                    completion(
                        .failure(
                            RecorderError.cameraDenied
                        )
                    )
                }
                return
            }

            AVCaptureDevice.requestAccess(
                for: .audio
            ) {
                microphoneGranted in

                DispatchQueue.main.async {
                    microphoneGranted
                    ? completion(
                        .success(())
                    )
                    : completion(
                        .failure(
                            RecorderError.microphoneDenied
                        )
                    )
                }
            }
        }
    }

    func configurePreview(
        in view: UIView
    ) throws {

        if !isConfigured {
            try configureSession()
        }

        let layer =
            AVCaptureVideoPreviewLayer(
                session: session
            )

        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.insertSublayer(
            layer,
            at: 0
        )

        previewLayer = layer
    }

    func updatePreviewFrame(
        _ frame: CGRect
    ) {

        previewLayer?.frame = frame
    }

    func startSession() {

        guard !session.isRunning else {
            return
        }

        DispatchQueue.global(
            qos: .userInitiated
        ).async {
            self.session.startRunning()
        }
    }

    func stopSession() {

        guard session.isRunning else {
            return
        }

        DispatchQueue.global(
            qos: .userInitiated
        ).async {
            self.session.stopRunning()
        }
    }

    func switchCamera() throws {

        currentCameraPosition =
            currentCameraPosition == .front
            ? .back
            : .front

        session.beginConfiguration()
        removeVideoInputs()

        do {

            try addVideoInput(
                position: currentCameraPosition
            )

            session.commitConfiguration()

        } catch {

            session.commitConfiguration()
            throw error
        }
    }

    func startRecording(
        to fileURL: URL,
        completion: @escaping (Result<(URL, TimeInterval), Error>) -> Void
    ) {

        finishHandler = completion
        outputURL = fileURL
        currentSegmentURL = nil
        currentSegmentStartedAt = nil
        segmentURLs = []
        accumulatedDuration = 0
        isRecordingSession = true
        isRecordingPaused = false
        isStoppingForPause = false
        isFinishingRecording = false
        shouldResumeAfterPauseStop = false

        startNewSegment()
    }

    private func startNewSegment() {

        guard let outputURL,
              isRecordingSession,
              !movieOutput.isRecording
        else {
            return
        }

        let segmentURL =
            outputURL
            .deletingLastPathComponent()
            .appendingPathComponent(
                "\(UUID().uuidString)-segment.mov"
            )

        currentSegmentURL = segmentURL
        currentSegmentStartedAt = Date()

        if let connection =
            movieOutput.connection(
                with: .video
            ) {

            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }

            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored =
                    currentCameraPosition == .front
            }
        }

        movieOutput.startRecording(
            to: segmentURL,
            recordingDelegate: self
        )
    }

    func stopRecording() {

        guard isRecordingSession else {
            return
        }

        isStoppingForPause = false
        isFinishingRecording = true

        if movieOutput.isRecording {
            movieOutput.stopRecording()
        } else {
            finishSegments()
        }
    }

    func pauseRecording() {

        guard isRecordingSession,
              movieOutput.isRecording,
              !isRecordingPaused
        else {
            return
        }

        isRecordingPaused = true
        isStoppingForPause = true
        shouldResumeAfterPauseStop = false
        movieOutput.stopRecording()
    }

    func resumeRecording() {

        guard isRecordingSession,
              isRecordingPaused
        else {
            return
        }

        if movieOutput.isRecording {
            shouldResumeAfterPauseStop = true
            isRecordingPaused = false
            return
        }

        isRecordingPaused = false
        isStoppingForPause = false
        startNewSegment()
    }

    private func appendFinishedSegment(
        _ segmentURL: URL,
        output: AVCaptureFileOutput
    ) {

        guard FileManager.default.fileExists(
            atPath: segmentURL.path
        ) else {
            return
        }

        segmentURLs.append(
            segmentURL
        )

        let recordedSeconds =
            CMTimeGetSeconds(
                output.recordedDuration
            )

        if recordedSeconds.isFinite,
           recordedSeconds > 0 {
            accumulatedDuration += recordedSeconds
        } else {
            accumulatedDuration +=
                Date().timeIntervalSince(
                    currentSegmentStartedAt ?? Date()
                )
        }
    }

    private func finishSegments() {

        guard let outputURL else {
            finish(
                .failure(
                    RecorderError.outputUnavailable
                )
            )
            return
        }

        guard !segmentURLs.isEmpty else {
            finish(
                .failure(
                    RecorderError.outputUnavailable
                )
            )
            return
        }

        do {
            try prepareOutputURL(
                outputURL
            )

            if segmentURLs.count == 1,
               let segmentURL = segmentURLs.first {
                try FileManager.default.moveItem(
                    at: segmentURL,
                    to: outputURL
                )

                finish(
                    .success(
                        (
                            outputURL,
                            accumulatedDuration
                        )
                    )
                )
                return
            }

            mergeSegments(
                into: outputURL
            )

        } catch {
            finish(
                .failure(error)
            )
        }
    }

    private func mergeSegments(
        into outputURL: URL
    ) {

        let composition =
            AVMutableComposition()

        guard let compositionTrack =
                composition.addMutableTrack(
                    withMediaType: .video,
                    preferredTrackID:
                        kCMPersistentTrackID_Invalid
                )
        else {
            finish(
                .failure(
                    RecorderError.outputUnavailable
                )
            )
            return
        }

        let audioCompositionTrack =
            composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID:
                    kCMPersistentTrackID_Invalid
            )

        var cursor =
            CMTime.zero

        do {
            for segmentURL in segmentURLs {
                let asset =
                    AVURLAsset(
                        url: segmentURL
                    )

                guard let track =
                        asset
                        .tracks(
                            withMediaType: .video
                        )
                        .first
                else {
                    continue
                }

                if cursor == .zero {
                    compositionTrack.preferredTransform =
                        track.preferredTransform
                }

                try compositionTrack.insertTimeRange(
                    CMTimeRange(
                        start: .zero,
                        duration: asset.duration
                    ),
                    of: track,
                    at: cursor
                )

                if let audioTrack =
                    asset
                    .tracks(
                        withMediaType: .audio
                    )
                    .first {

                    try audioCompositionTrack?.insertTimeRange(
                        CMTimeRange(
                            start: .zero,
                            duration: asset.duration
                        ),
                        of: audioTrack,
                        at: cursor
                    )
                }

                cursor =
                    CMTimeAdd(
                        cursor,
                        asset.duration
                    )
            }

            guard let exporter =
                    AVAssetExportSession(
                        asset: composition,
                        presetName:
                            AVAssetExportPresetHighestQuality
                    )
            else {
                throw RecorderError.outputUnavailable
            }

            exporter.outputURL = outputURL
            exporter.outputFileType =
                exporter
                .supportedFileTypes
                .contains(
                    .mov
                )
                ? .mov
                : (
                    exporter.supportedFileTypes.first
                    ?? .mov
                )
            exporter.shouldOptimizeForNetworkUse = true

            exporter.exportAsynchronously {
                DispatchQueue.main.async {
                    switch exporter.status {
                    case .completed:
                        self.finish(
                            .success(
                                (
                                    outputURL,
                                    self.accumulatedDuration
                                )
                            )
                        )

                    case .failed,
                         .cancelled:
                        self.finish(
                            .failure(
                                exporter.error
                                ?? RecorderError.outputUnavailable
                            )
                        )

                    default:
                        self.finish(
                            .failure(
                                RecorderError.outputUnavailable
                            )
                        )
                    }
                }
            }

        } catch {
            finish(
                .failure(error)
            )
        }
    }

    private func prepareOutputURL(
        _ outputURL: URL
    ) throws {

        try FileManager.default.createDirectory(
            at: outputURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        if FileManager.default.fileExists(
            atPath: outputURL.path
        ) {
            try FileManager.default.removeItem(
                at: outputURL
            )
        }
    }

    private func finish(
        _ result: Result<(URL, TimeInterval), Error>
    ) {

        finishHandler?(
            result
        )

        cleanupSegments()
        finishHandler = nil
        outputURL = nil
        currentSegmentURL = nil
        currentSegmentStartedAt = nil
        segmentURLs = []
        accumulatedDuration = 0
        isRecordingSession = false
        isRecordingPaused = false
        isStoppingForPause = false
        isFinishingRecording = false
        shouldResumeAfterPauseStop = false
    }

    private func cleanupSegments() {

        for segmentURL in segmentURLs {
            try? FileManager.default.removeItem(
                at: segmentURL
            )
        }
    }

    private func configureSession() throws {

        session.beginConfiguration()
        session.sessionPreset = .high

        try addVideoInput(
            position: currentCameraPosition
        )
        try addAudioInput()

        guard session.canAddOutput(
            movieOutput
        )
        else {
            session.commitConfiguration()
            throw RecorderError.outputUnavailable
        }

        session.addOutput(
            movieOutput
        )

        session.commitConfiguration()
        isConfigured = true
    }

    private func addVideoInput(
        position: AVCaptureDevice.Position
    ) throws {

        guard let device =
            AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: position
            )
        else {
            throw RecorderError.cameraUnavailable
        }

        let input =
            try AVCaptureDeviceInput(
                device: device
            )

        guard session.canAddInput(
            input
        )
        else {
            throw RecorderError.cameraUnavailable
        }

        session.addInput(
            input
        )
    }

    private func addAudioInput() throws {

        guard let device =
            AVCaptureDevice.default(
                for: .audio
            )
        else {
            return
        }

        let input =
            try AVCaptureDeviceInput(
                device: device
            )

        if session.canAddInput(
            input
        ) {
            session.addInput(
                input
            )
        }
    }

    private func removeVideoInputs() {

        session.inputs
            .compactMap {
                $0 as? AVCaptureDeviceInput
            }
            .filter {
                $0.device.hasMediaType(
                    .video
                )
            }
            .forEach {
                session.removeInput(
                    $0
                )
            }
    }
}

extension ScriptVideoRecorder: AVCaptureFileOutputRecordingDelegate {

    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {

        if let error {
            finish(
                .failure(error)
            )
            return
        }

        appendFinishedSegment(
            outputFileURL,
            output: output
        )

        currentSegmentURL = nil
        currentSegmentStartedAt = nil

        if isStoppingForPause {
            isStoppingForPause = false

            if shouldResumeAfterPauseStop {
                shouldResumeAfterPauseStop = false
                isRecordingPaused = false
                startNewSegment()
                return
            }

            isRecordingPaused = true
            return
        }

        if isFinishingRecording {
            finishSegments()
            return
        }

        finishSegments()
    }
}
