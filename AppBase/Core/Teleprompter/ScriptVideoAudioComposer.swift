//
//  ScriptVideoAudioComposer.swift
//  AppBase
//

import AVFoundation
import Foundation

final class ScriptVideoAudioComposer {

    enum AudioMode {
        case scriptOnly
        case originalOnly
        case originalAndScript
    }

    enum ComposerError: LocalizedError {
        case missingVideoTrack
        case cannotCreateExporter

        var errorDescription: String? {
            switch self {
            case .missingVideoTrack:
                return "Không tìm thấy video track để xử lý."
            case .cannotCreateExporter:
                return "Không thể tạo file video đã ghép giọng đọc."
            }
        }
    }

    func replaceAudio(
        in videoURL: URL,
        with speechAudioURL: URL?,
        outputURL: URL,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {

        compose(
            videoURL: videoURL,
            speechAudioURL: speechAudioURL,
            outputURL: outputURL,
            timeRange: nil,
            audioMode: .scriptOnly,
            completion: completion
        )
    }

    func compose(
        videoURL: URL,
        speechAudioURL: URL?,
        outputURL: URL,
        timeRange: CMTimeRange? = nil,
        audioMode: AudioMode,
        originalVolume: Float = 1.0,
        scriptVolume: Float = 1.0,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {

        DispatchQueue.global(
            qos: .userInitiated
        ).async {

            do {
                try self.prepareOutputURL(
                    outputURL
                )

                let videoAsset =
                    AVURLAsset(
                        url: videoURL
                    )

                let composition =
                    AVMutableComposition()

                guard let videoTrack =
                        videoAsset
                        .tracks(
                            withMediaType: .video
                        )
                        .first
                else {
                    throw ComposerError.missingVideoTrack
                }

                let videoDuration =
                    videoAsset.duration

                let requestedTimeRange =
                    timeRange
                    ?? CMTimeRange(
                        start: .zero,
                        duration: videoDuration
                    )

                let safeTimeRange =
                    self.clampedTimeRange(
                        requestedTimeRange,
                        assetDuration: videoDuration
                    )

                guard let videoCompositionTrack =
                    composition.addMutableTrack(
                        withMediaType: .video,
                        preferredTrackID:
                            kCMPersistentTrackID_Invalid
                    )
                else {
                    throw ComposerError.cannotCreateExporter
                }

                try videoCompositionTrack.insertTimeRange(
                    safeTimeRange,
                    of: videoTrack,
                    at: .zero
                )

                videoCompositionTrack.preferredTransform =
                    videoTrack.preferredTransform

                var audioMixParameters: [AVAudioMixInputParameters] = []

                if audioMode == .originalOnly
                    || audioMode == .originalAndScript {

                    let originalAudioTracks =
                        try self.insertOriginalAudio(
                            from: videoAsset,
                            into: composition,
                            timeRange: safeTimeRange
                        )

                    for originalAudioTrack in originalAudioTracks {
                        audioMixParameters.append(
                            self.audioMixParameters(
                                for: originalAudioTrack,
                                volume: originalVolume
                            )
                        )
                    }
                }

                if let speechAudioURL,
                   (
                    audioMode == .scriptOnly
                    || audioMode == .originalAndScript
                   ) {

                    if let scriptAudioTrack =
                        try self.insertSpeechAudio(
                            from: speechAudioURL,
                            into: composition,
                            sourceStart: safeTimeRange.start,
                            maxDuration: safeTimeRange.duration
                        ) {

                        audioMixParameters.append(
                            self.audioMixParameters(
                                for: scriptAudioTrack,
                                volume: scriptVolume
                            )
                        )
                    }
                }

                guard let exporter =
                        AVAssetExportSession(
                            asset: composition,
                            presetName:
                                AVAssetExportPresetHighestQuality
                        )
                else {
                    throw ComposerError.cannotCreateExporter
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
                exporter.shouldOptimizeForNetworkUse = true

                if !audioMixParameters.isEmpty {
                    let audioMix =
                        AVMutableAudioMix()

                    audioMix.inputParameters =
                        audioMixParameters
                    exporter.audioMix = audioMix
                }

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
                                    ?? ComposerError.cannotCreateExporter
                                )
                            )

                        default:
                            completion(
                                .failure(
                                    ComposerError.cannotCreateExporter
                                )
                            )
                        }
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    completion(
                        .failure(error)
                    )
                }
            }
        }
    }

    private func insertOriginalAudio(
        from videoAsset: AVURLAsset,
        into composition: AVMutableComposition,
        timeRange: CMTimeRange
    ) throws -> [AVMutableCompositionTrack] {

        try videoAsset
            .tracks(
                withMediaType: .audio
            )
            .compactMap {
                audioTrack -> AVMutableCompositionTrack? in

                guard let audioCompositionTrack =
                composition.addMutableTrack(
                    withMediaType: .audio,
                    preferredTrackID:
                        kCMPersistentTrackID_Invalid
                )
                else {
                    return nil
                }

                try audioCompositionTrack.insertTimeRange(
                    timeRange,
                    of: audioTrack,
                    at: .zero
                )

                return audioCompositionTrack
            }
    }

    private func insertSpeechAudio(
        from audioURL: URL,
        into composition: AVMutableComposition,
        sourceStart: CMTime,
        maxDuration: CMTime
    ) throws -> AVMutableCompositionTrack? {

        let audioAsset =
            AVURLAsset(
                url: audioURL
            )

        guard let audioTrack =
                audioAsset
                .tracks(
                    withMediaType: .audio
                )
                .first
        else {
            return nil
        }

        let audioDuration =
            CMTimeCompare(
                CMTimeSubtract(
                    audioAsset.duration,
                    sourceStart
                ),
                maxDuration
            ) < 0
            ? CMTimeSubtract(
                audioAsset.duration,
                sourceStart
            )
            : maxDuration

        guard audioDuration.seconds > 0 else {
            return nil
        }

        guard let audioCompositionTrack =
            composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID:
                    kCMPersistentTrackID_Invalid
            )
        else {
            return nil
        }

        try audioCompositionTrack.insertTimeRange(
            CMTimeRange(
                start: sourceStart,
                duration: audioDuration
            ),
            of: audioTrack,
            at: .zero
        )

        return audioCompositionTrack
    }

    private func audioMixParameters(
        for track: AVCompositionTrack,
        volume: Float
    ) -> AVAudioMixInputParameters {

        let parameters =
            AVMutableAudioMixInputParameters(
                track: track
            )

        parameters.setVolume(
            max(
                0,
                volume
            ),
            at: .zero
        )

        return parameters
    }

    private func clampedTimeRange(
        _ timeRange: CMTimeRange,
        assetDuration: CMTime
    ) -> CMTimeRange {

        let start =
            CMTimeMaximum(
                .zero,
                CMTimeMinimum(
                    timeRange.start,
                    assetDuration
                )
            )

        let requestedEnd =
            CMTimeAdd(
                timeRange.start,
                timeRange.duration
            )

        let end =
            CMTimeMaximum(
                start,
                CMTimeMinimum(
                    requestedEnd,
                    assetDuration
                )
            )

        return CMTimeRange(
            start: start,
            duration:
                CMTimeSubtract(
                    end,
                    start
                )
        )
    }

    private func prepareOutputURL(
        _ outputURL: URL
    ) throws {

        let directory =
            outputURL.deletingLastPathComponent()

        try FileManager.default.createDirectory(
            at: directory,
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
}
