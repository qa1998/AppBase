//
//  RecordScriptViewModel.swift
//  AppBase
//

import AVFoundation
import Foundation

final class RecordScriptViewModel: TIOViewModel {

    let script: TeleprompterScript

    private static let selectedVoiceIdentifierKey =
        "teleprompter.selectedVoiceIdentifier"

    private let recordingRepository: ScriptRecordingRepository
    private var speechExporter: SpeechManager?

    private(set) var recordings: [ScriptRecording] = []
    private(set) var isProcessingRecording = false

    var onRecordingsChanged: (() -> Void)?
    var onProcessingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    init(
        script: TeleprompterScript,
        recordingRepository: ScriptRecordingRepository = .shared
    ) {

        self.script = script
        self.recordingRepository = recordingRepository

        super.init()

        reloadRecordings()
    }

    func reloadRecordings() {

        recordings =
            recordingRepository.recordings(
                scriptId: script.id
            )

        onRecordingsChanged?()
    }

    func recording(
        at index: Int
    ) -> ScriptRecording? {

        recordings.indices.contains(index)
        ? recordings[index]
        : nil
    }

    func deleteRecording(
        _ recording: ScriptRecording
    ) {

        recordingRepository.delete(
            recording
        )

        reloadRecordings()
    }

    func prepareTrimSpeechAudio(
        for recording: ScriptRecording,
        baseURL: URL,
        completion: @escaping (URL?, Bool) -> Void
    ) {

        if let scriptAudioURL =
            scriptAudioURL(
                for: recording
            ) {

            completion(
                scriptAudioURL,
                false
            )
            return
        }

        guard !isProcessingRecording else {
            return
        }

        isProcessingRecording = true
        onProcessingChanged?(true)

        exportSpeechAudio(
            baseURL: baseURL
        ) {
            [weak self]
            speechAudioURL in

            self?.finishProcessing()
            completion(
                speechAudioURL,
                true
            )
        }
    }

    func trimRecording(
        _ recording: ScriptRecording,
        startTime: TimeInterval,
        endTime: TimeInterval,
        audioMode: ScriptVideoAudioComposer.AudioMode,
        originalVolume: Float,
        scriptVolume: Float
    ) {

        guard !isProcessingRecording else {
            return
        }

        let duration =
            max(
                0.1,
                endTime - startTime
            )

        guard duration > 0.1 else {
            return
        }

        isProcessingRecording = true
        onProcessingChanged?(true)

        let sourceURL =
            fileURL(
                for: recording
            )

        let outputURL =
            makeTemporaryURL(
                baseURL: sourceURL,
                fileExtension:
                    sourceURL.pathExtension.isEmpty
                    ? "mov"
                    : sourceURL.pathExtension
            )

        exportTrimmedVideo(
            sourceURL: sourceURL,
            outputURL: outputURL,
            startTime: startTime,
            duration: duration
        ) {
            [weak self]
            result in

            guard let self else {
                return
            }

            switch result {
            case let .success(url):
                do {
                    try self.replaceRawVideo(
                        rawURL: sourceURL,
                        processedURL: url
                    )

                    let updatedRecording =
                        ScriptRecording(
                            id: recording.id,
                            scriptId: recording.scriptId,
                            fileName: recording.fileName,
                            scriptAudioFileName:
                                recording.scriptAudioFileName,
                            createdAt: recording.createdAt,
                            duration: duration,
                            audioMode:
                                audioMode.rawStorageValue,
                            originalVolume: originalVolume,
                            scriptVolume: scriptVolume
                        )

                    self.trimScriptAudioIfNeeded(
                        for: updatedRecording,
                        sourceRecording: recording,
                        sourceVideoURL: sourceURL,
                        startTime: startTime,
                        duration: duration
                    ) {
                        [weak self]
                        finalRecording in

                        guard let self else {
                            return
                        }

                        self.recordingRepository.save(
                            finalRecording
                        )
                        self.reloadRecordings()
                        self.finishProcessing()
                    }

                } catch {
                    self.cleanupTemporaryFile(
                        outputURL
                    )
                    self.handleProcessingError(
                        error
                    )
                }

            case let .failure(error):
                self.cleanupTemporaryFile(
                    outputURL
                )
                self.handleProcessingError(
                    error
                )
            }
        }
    }

    func makeVideoOutputURL() throws -> URL {

        try recordingRepository.createFileURL(
            scriptId: script.id
        )
    }

    func saveVideoRecording(
        fileURL: URL,
        duration: TimeInterval
    ) {

        guard !isProcessingRecording else {
            return
        }

        isProcessingRecording = true
        onProcessingChanged?(true)

        exportSpeechAudio(
            baseURL: fileURL
        ) {
            [weak self]
            speechAudioURL in

            guard let self else {
                return
            }

            self.persistRecording(
                fileURL: fileURL,
                duration: duration,
                scriptAudioFileName:
                    speechAudioURL?
                    .lastPathComponent,
                audioMode: .originalAndScript,
                originalVolume: 1.0,
                scriptVolume: 1.0
            )
        }
    }

    func importVideo(
        from sourceURL: URL
    ) {

        guard !isProcessingRecording else {
            return
        }

        isProcessingRecording = true
        onProcessingChanged?(true)

        do {
            let fileExtension =
                sourceURL.pathExtension.isEmpty
                ? "mov"
                : sourceURL.pathExtension

            let destinationURL =
                try recordingRepository.createFileURL(
                    scriptId: script.id,
                    fileExtension: fileExtension
                )

            if FileManager.default.fileExists(
                atPath: destinationURL.path
            ) {
                try FileManager.default.removeItem(
                    at: destinationURL
                )
            }

            try FileManager.default.copyItem(
                at: sourceURL,
                to: destinationURL
            )

            let duration =
                videoDuration(
                    at: destinationURL
                )

            exportSpeechAudio(
                baseURL: destinationURL
            ) {
                [weak self]
                speechAudioURL in

                guard let self else {
                    return
                }

                self.persistRecording(
                    fileURL: destinationURL,
                    duration: duration,
                    scriptAudioFileName:
                        speechAudioURL?
                        .lastPathComponent,
                    audioMode: .originalAndScript,
                    originalVolume: 1.0,
                    scriptVolume: 1.0
                )
            }

        } catch {
            handleProcessingError(
                error
            )
        }
    }

    private func persistRecording(
        fileURL: URL,
        duration: TimeInterval,
        scriptAudioFileName: String?,
        audioMode: ScriptVideoAudioComposer.AudioMode,
        originalVolume: Float,
        scriptVolume: Float
    ) {

        let recording =
            ScriptRecording(
                scriptId: script.id,
                fileName: fileURL.lastPathComponent,
                scriptAudioFileName: scriptAudioFileName,
                duration: duration,
                audioMode: audioMode.rawStorageValue,
                originalVolume: originalVolume,
                scriptVolume: scriptVolume
            )

        recordingRepository.save(
            recording
        )

        reloadRecordings()
        finishProcessing()
    }

    private func videoDuration(
        at url: URL
    ) -> TimeInterval {

        let duration =
            AVURLAsset(
                url: url
            ).duration

        let seconds =
            CMTimeGetSeconds(
                duration
            )

        return seconds.isFinite
        ? seconds
        : 0
    }

    private func exportTrimmedVideo(
        sourceURL: URL,
        outputURL: URL,
        startTime: TimeInterval,
        duration: TimeInterval,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {

        cleanupTemporaryFile(
            outputURL
        )

        let asset =
            AVURLAsset(
                url: sourceURL
            )

        guard let exporter =
                AVAssetExportSession(
                    asset: asset,
                    presetName:
                        AVAssetExportPresetHighestQuality
                )
        else {
            completion(
                .failure(
                    NSError(
                        domain: "RecordTrim",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "Không thể tạo file trim."
                        ]
                    )
                )
            )
            return
        }

        let outputFileType: AVFileType =
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

        exporter.outputURL = outputURL
        exporter.outputFileType = outputFileType
        exporter.timeRange =
            CMTimeRange(
                start:
                    CMTime(
                        seconds: startTime,
                        preferredTimescale: 600
                    ),
                duration:
                    CMTime(
                        seconds: duration,
                        preferredTimescale: 600
                    )
            )
        exporter.shouldOptimizeForNetworkUse = true

        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                switch exporter.status {
                case .completed:
                    completion(
                        .success(outputURL)
                    )

                case .failed,
                     .cancelled:
                    completion(
                        .failure(
                            exporter.error
                            ?? NSError(
                                domain: "RecordTrim",
                                code: -2,
                                userInfo: [
                                    NSLocalizedDescriptionKey:
                                        "Không thể lưu video đã trim."
                                ]
                            )
                        )
                    )

                default:
                    completion(
                        .failure(
                            NSError(
                                domain: "RecordTrim",
                                code: -3,
                                userInfo: [
                                    NSLocalizedDescriptionKey:
                                        "Không thể lưu video đã trim."
                                ]
                            )
                        )
                    )
                }
            }
        }
    }

    private func trimScriptAudioIfNeeded(
        for recording: ScriptRecording,
        sourceRecording: ScriptRecording,
        sourceVideoURL: URL,
        startTime: TimeInterval,
        duration: TimeInterval,
        completion: @escaping (ScriptRecording) -> Void
    ) {

        if let existingScriptAudioURL =
            scriptAudioURL(
                for: sourceRecording
            ) {

            trimScriptAudio(
                sourceURL: existingScriptAudioURL,
                recording: recording,
                startTime: startTime,
                duration: duration,
                cleanupSourceOnSuccess: true,
                completion: completion
            )
            return
        }

        exportSpeechAudio(
            baseURL: sourceVideoURL
        ) {
            [weak self]
            speechAudioURL in

            guard let self,
                  let speechAudioURL
            else {
                completion(recording)
                return
            }

            self.trimScriptAudio(
                sourceURL: speechAudioURL,
                recording: recording,
                startTime: startTime,
                duration: duration,
                cleanupSourceOnSuccess: true,
                completion: completion
            )
        }
    }

    private func trimScriptAudio(
        sourceURL: URL,
        recording: ScriptRecording,
        startTime: TimeInterval,
        duration: TimeInterval,
        cleanupSourceOnSuccess: Bool,
        completion: @escaping (ScriptRecording) -> Void
    ) {

        let outputURL =
            makeTemporaryURL(
                baseURL: sourceURL,
                fileExtension: "caf"
            )

        exportTrimmedAudio(
            sourceURL: sourceURL,
            outputURL: outputURL,
            startTime: startTime,
            duration: duration
        ) {
            [weak self]
            result in

            guard let self else {
                return
            }

            switch result {
            case let .success(url):
                if cleanupSourceOnSuccess {
                    self.cleanupTemporaryFile(
                        sourceURL
                    )
                }

                completion(
                    ScriptRecording(
                        id: recording.id,
                        scriptId: recording.scriptId,
                        fileName: recording.fileName,
                        scriptAudioFileName: url.lastPathComponent,
                        createdAt: recording.createdAt,
                        duration: recording.duration,
                        audioMode: recording.audioMode,
                        originalVolume: recording.originalVolume,
                        scriptVolume: recording.scriptVolume
                    )
                )

            case .failure:
                self.cleanupTemporaryFile(
                    outputURL
                )
                completion(recording)
            }
        }
    }

    private func exportTrimmedAudio(
        sourceURL: URL,
        outputURL: URL,
        startTime: TimeInterval,
        duration: TimeInterval,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {

        cleanupTemporaryFile(
            outputURL
        )

        let asset =
            AVURLAsset(
                url: sourceURL
            )

        guard let audioTrack =
                asset
                .tracks(
                    withMediaType: .audio
                )
                .first
        else {
            completion(
                .failure(
                    NSError(
                        domain: "RecordTrimAudio",
                        code: -1
                    )
                )
            )
            return
        }

        let composition =
            AVMutableComposition()

        guard let compositionTrack =
                composition.addMutableTrack(
                    withMediaType: .audio,
                    preferredTrackID:
                        kCMPersistentTrackID_Invalid
                )
        else {
            completion(
                .failure(
                    NSError(
                        domain: "RecordTrimAudio",
                        code: -2
                    )
                )
            )
            return
        }

        do {
            try compositionTrack.insertTimeRange(
                CMTimeRange(
                    start:
                        CMTime(
                            seconds: startTime,
                            preferredTimescale: 600
                        ),
                    duration:
                        CMTime(
                            seconds: duration,
                            preferredTimescale: 600
                        )
                ),
                of: audioTrack,
                at: .zero
            )

            guard let exporter =
                    AVAssetExportSession(
                        asset: composition,
                        presetName:
                            AVAssetExportPresetAppleM4A
                    )
            else {
                throw NSError(
                    domain: "RecordTrimAudio",
                    code: -3
                )
            }

            let finalOutputURL =
                outputURL
                .deletingPathExtension()
                .appendingPathExtension("m4a")

            cleanupTemporaryFile(
                finalOutputURL
            )

            exporter.outputURL = finalOutputURL
            exporter.outputFileType = .m4a
            exporter.timeRange =
                CMTimeRange(
                    start: .zero,
                    duration:
                        CMTime(
                            seconds: duration,
                            preferredTimescale: 600
                        )
                )

            exporter.exportAsynchronously {
                DispatchQueue.main.async {
                    switch exporter.status {
                    case .completed:
                        completion(
                            .success(finalOutputURL)
                        )

                    case .failed,
                         .cancelled:
                        completion(
                            .failure(
                                exporter.error
                                ?? NSError(
                                    domain: "RecordTrimAudio",
                                    code: -4
                                )
                            )
                        )

                    default:
                        completion(
                            .failure(
                                NSError(
                                    domain: "RecordTrimAudio",
                                    code: -5
                                )
                            )
                        )
                    }
                }
            }

        } catch {
            completion(
                .failure(error)
            )
        }
    }

    private func exportSpeechAudio(
        baseURL: URL,
        completion: @escaping (URL?) -> Void
    ) {

        let text =
            script.content.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !text.isEmpty else {
            completion(nil)
            return
        }

        let audioURL =
            makeTemporaryURL(
                baseURL: baseURL,
                fileExtension: "caf"
            )

        cleanupTemporaryFile(
            audioURL
        )

        let speech =
            SpeechManager()

        speech.setText(
            script.content
        )
        speech.voice = selectedAppleVoice()
        speech.configuration.rate = 0.46
        speech.configuration.pitchMultiplier = 1.02
        speech.configuration.volume = 1.0

        speechExporter = speech

        speech.exportSpeech(
            to: audioURL
        ) {
            [weak self]
            result in

            self?.speechExporter = nil

            switch result {
            case let .success(url):
                completion(url)

            case let .failure(error):
                self?.cleanupTemporaryFile(
                    audioURL
                )
                self?.handleProcessingError(
                    error
                )
            }
        }
    }

    private func replaceRawVideo(
        rawURL: URL,
        processedURL: URL
    ) throws {

        if FileManager.default.fileExists(
            atPath: rawURL.path
        ) {
            try FileManager.default.removeItem(
                at: rawURL
            )
        }

        try FileManager.default.moveItem(
            at: processedURL,
            to: rawURL
        )
    }

    private func handleProcessingError(
        _ error: Error
    ) {

        onError?(
            error.localizedDescription
        )
        finishProcessing()
    }

    private func finishProcessing() {

        isProcessingRecording = false
        onProcessingChanged?(false)
    }

    private func cleanupTemporaryFile(
        _ url: URL?
    ) {

        guard let url else {
            return
        }

        try? FileManager.default.removeItem(
            at: url
        )
    }

    private func makeTemporaryURL(
        baseURL: URL?,
        fileExtension: String
    ) -> URL {

        let directory =
            baseURL?
            .deletingLastPathComponent()
            ?? FileManager.default.temporaryDirectory

        return directory.appendingPathComponent(
            "\(UUID().uuidString).\(fileExtension)"
        )
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

    func fileURL(
        for recording: ScriptRecording
    ) -> URL {

        recordingRepository.fileURL(
            for: recording
        )
    }

    func scriptAudioURL(
        for recording: ScriptRecording
    ) -> URL? {

        recordingRepository.scriptAudioURL(
            for: recording
        )
    }

    func audioMode(
        for recording: ScriptRecording
    ) -> ScriptVideoAudioComposer.AudioMode {

        ScriptVideoAudioComposer.AudioMode(
            storageValue: recording.audioMode
        )
    }

    func originalVolume(
        for recording: ScriptRecording
    ) -> Float {

        recording.originalVolume ?? 1.0
    }

    func scriptVolume(
        for recording: ScriptRecording
    ) -> Float {

        recording.scriptVolume ?? 1.0
    }
}

private extension ScriptVideoAudioComposer.AudioMode {

    var rawStorageValue: String {
        switch self {
        case .scriptOnly:
            return "scriptOnly"

        case .originalOnly:
            return "originalOnly"

        case .originalAndScript:
            return "originalAndScript"
        }
    }

    init(storageValue: String?) {
        switch storageValue {
        case "scriptOnly":
            self = .scriptOnly

        case "originalOnly":
            self = .originalOnly

        default:
            self = .originalAndScript
        }
    }
}
