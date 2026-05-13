//
//  PlayScriptViewModel.swift
//

import AVFoundation
import BaseMVVM
import CoreGraphics
import Foundation

final class PlayScriptViewModel: TIOViewModel {

    enum ExportError: LocalizedError {
        case alreadyExporting

        var errorDescription: String? {
            switch self {
            case .alreadyExporting:
                return L10n.speechExportErrorAlreadyExporting
            }
        }
    }

    struct VoiceOption {
        let identifier: String
        let name: String
        let language: String
        let quality: String
        let isSelected: Bool

        var title: String {
            L10n.speechVoiceNameLanguageFormat(
                name,
                language
            )
        }

        var subtitle: String {
            quality
        }
    }

    struct RemoteVoiceOption {
        let id: String
        let title: String
        let previewURL: URL?
    }

    let script: TeleprompterScript

    private static let selectedVoiceIdentifierKey =
        "teleprompter.selectedVoiceIdentifier"

    private let speech = SpeechManager()
    private lazy var elevenLabsProvider =
        ElevenLabsSpeechProvider {
            ElevenLabsCredentialStore.apiKey()
        }

    private let baseSpeechRate: Float = 0.46
    private(set) var speechRateMultiplier: Float = 1.0
    private var currentReadOffsetUTF16: Int = 0
    private var isRestartingSpeech = false

    var onProgressTick: ((TimeInterval, Double) -> Void)?
    var onPlayStateChanged: ((Bool) -> Void)?
    var onSpokenRange: ((NSRange, String) -> Void)?
    var onSeekToCharacter: ((Int) -> Void)?
    var onSpeechRateChanged: ((Float) -> Void)?
    var onFontSizeChanged: ((CGFloat) -> Void)?
    var onExportStateChanged: ((Bool) -> Void)?
    var onVoiceChanged: ((String) -> Void)?

    private var progressTimer: Timer?

    private var activeSegmentStart: Date?
    private var accumulatedElapsed: TimeInterval = 0

    private(set)
    var isPlaybackSessionActive: Bool = false

    var mirrorEnabled = false
    var autoResumeFromLastPosition = true

    private(set) var fontSize: CGFloat = 34
    private(set) var isExportingSpeech = false

    init(script: TeleprompterScript) {

        self.script = script

        super.init()

        speech.delegate = self

        speech.setText(
            script.content
        )

        applySpeechConfiguration()

        loadSelectedVoice()
    }

    func togglePlayPause() {

        if speech.isUtteranceActive {

            if speech.isPaused {

                speech.resume()

                activeSegmentStart = Date()

            } else {

                speech.pause()

                pauseClock()
            }

            onPlayStateChanged?(
                speech.isSynthesizerSpeaking
            )

            return
        }

        startPlayback()
    }

    func adjustSpeechRate(by delta: Float) {

        setSpeechRateMultiplier(
            speechRateMultiplier + delta
        )
    }

    func setSpeechRateMultiplier(_ value: Float) {

        speechRateMultiplier =
            min(
                1.7,
                max(
                    0.55,
                    value
                )
            )

        applySpeechConfiguration()

        onSpeechRateChanged?(
            speechRateMultiplier
        )

        restartSpeechIfNeeded()
    }

    func adjustFontSize(by delta: CGFloat) {

        setFontSize(
            fontSize + delta
        )
    }

    func setFontSize(_ value: CGFloat) {

        fontSize =
            min(
                54,
                max(
                    24,
                    value
                )
            )

        onFontSizeChanged?(
            fontSize
        )
    }

    func seekToCharacter(_ utf16Offset: Int) {

        let clamped =
            clampedOffset(
                utf16Offset
            )

        currentReadOffsetUTF16 = clamped

        TeleprompterPlaybackStore.saveLastReadOffset(
            clamped,
            scriptId: script.id
        )

        onSeekToCharacter?(
            clamped
        )

        emitProgress()

        guard speech.isUtteranceActive || isPlaybackSessionActive else {
            return
        }

        isRestartingSpeech = true

        speech.speak(
            from: clamped
        )

        isRestartingSpeech = false

        isPlaybackSessionActive = true

        if activeSegmentStart == nil {
            activeSegmentStart = Date()
        }

        startProgressTimer()

        onPlayStateChanged?(true)
    }

    func stopPlayback() {

        speech.stop()

        progressTimer?.invalidate()

        progressTimer = nil

        pauseClock()

        isPlaybackSessionActive = false

        onPlayStateChanged?(false)
    }

    func exportSpeechToFile(
        completion: @escaping (Result<URL, Error>) -> Void
    ) {

        guard !isExportingSpeech else {
            completion(
                .failure(
                    ExportError.alreadyExporting
                )
            )
            return
        }

        do {

            let outputURL =
                try makeExportFileURL()

            isExportingSpeech = true

            onExportStateChanged?(true)

            speech.exportSpeech(
                to: outputURL
            ) {
                [weak self]
                result in

                self?.isExportingSpeech = false

                self?.onExportStateChanged?(false)

                completion(result)
            }

        } catch {

            completion(
                .failure(error)
            )
        }
    }

    func saveElevenLabsAPIKey(
        _ apiKey: String
    ) throws {

        try ElevenLabsCredentialStore.saveAPIKey(
            apiKey
        )
    }

    func fetchElevenLabsVoices(
        completion: @escaping (Result<[RemoteVoiceOption], Error>) -> Void
    ) {

        elevenLabsProvider.fetchVoices {
            result in

            completion(
                result.map {
                    voices in

                    voices.map {
                        RemoteVoiceOption(
                            id: $0.id,
                            title: $0.displayName,
                            previewURL: $0.previewURL
                        )
                    }
                }
            )
        }
    }

    func exportSpeechWithElevenLabs(
        voiceId: String,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {

        do {

            let outputURL =
                try makeExportFileURL(
                    fileExtension: "mp3"
                )

            elevenLabsProvider.synthesizeSpeech(
                request:
                    RemoteSpeechRequest(
                        text: script.content,
                        voiceId: voiceId,
                        outputURL: outputURL
                    ),
                completion: completion
            )

        } catch {

            completion(
                .failure(error)
            )
        }
    }

    func availableVoiceOptions() -> [VoiceOption] {

        let selectedIdentifier =
            speech.voice?.identifier

        return SpeechManager
            .availableAppleVoices()
            .map {
                voice in

                VoiceOption(
                    identifier: voice.identifier,
                    name: voice.name,
                    language: voice.language,
                    quality: qualityDescription(
                        for: voice
                    ),
                    isSelected: voice.identifier == selectedIdentifier
                )
            }
    }

    func selectVoice(
        identifier: String
    ) {

        guard let voice =
                SpeechManager.appleVoice(
                    identifier: identifier
                )
        else {
            return
        }

        speech.voice = voice

        UserDefaults.standard.set(
            identifier,
            forKey: Self.selectedVoiceIdentifierKey
        )

        onVoiceChanged?(
            voice.name
        )

        restartSpeechIfNeeded()
    }

    private func startPlayback() {

        let resumeOffset =
            autoResumeFromLastPosition
            ? TeleprompterPlaybackStore.lastReadOffset(
                scriptId: script.id
            )
            : 0

        let offset =
            resumeOffset >= speech.fullTextLengthUTF16
            ? 0
            : clampedOffset(
                resumeOffset
            )

        currentReadOffsetUTF16 = offset

        onSeekToCharacter?(
            offset
        )

        speech.speak(from: offset)

        isPlaybackSessionActive = true

        accumulatedElapsed = 0

        activeSegmentStart = Date()

        startProgressTimer()

        onPlayStateChanged?(true)
    }

    private func restartSpeechIfNeeded() {

        guard speech.isUtteranceActive || isPlaybackSessionActive else {
            return
        }

        isRestartingSpeech = true

        speech.speak(
            from: currentReadOffsetUTF16
        )

        isRestartingSpeech = false

        isPlaybackSessionActive = true

        onPlayStateChanged?(true)
    }

    private func applySpeechConfiguration() {

        let rate =
            baseSpeechRate * speechRateMultiplier

        speech.configuration.rate =
            min(
                AVSpeechUtteranceMaximumSpeechRate,
                max(
                    AVSpeechUtteranceMinimumSpeechRate,
                    rate
                )
            )

        speech.configuration.pitchMultiplier = 1.02

        speech.configuration.volume = 1.0
    }

    private func loadSelectedVoice() {

        if let identifier =
            UserDefaults.standard.string(
                forKey: Self.selectedVoiceIdentifierKey
            ),
           let voice =
            SpeechManager.appleVoice(
                identifier: identifier
            ) {

            speech.voice = voice

        } else {

            speech.voice =
                SpeechManager
                    .availableAppleVoices()
                    .first {
                        $0.language == "vi-VN"
                    }
                ?? AVSpeechSynthesisVoice(
                    language: "vi-VN"
                )
        }

        if let voiceName =
            speech.voice?.name {

            onVoiceChanged?(
                voiceName
            )
        }
    }

    private func qualityDescription(
        for voice: AVSpeechSynthesisVoice
    ) -> String {

        if voice.quality.rawValue >= 3 {
            return L10n.speechVoiceQualityPremium
        }

        if voice.quality == .enhanced {
            return L10n.speechVoiceQualityEnhanced
        }

        return L10n.speechVoiceQualityDefault
    }

    private func clampedOffset(_ offset: Int) -> Int {
        max(
            0,
            min(
                offset,
                speech.fullTextLengthUTF16
            )
        )
    }

    private func makeExportFileURL(
        fileExtension: String = "caf"
    ) throws -> URL {

        let documentsURL =
            try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )

        let exportDirectory =
            documentsURL.appendingPathComponent(
                L10n.teleprompterExportDirectoryName,
                isDirectory: true
            )

        try FileManager.default.createDirectory(
            at: exportDirectory,
            withIntermediateDirectories: true
        )

        let title =
            script.title.isEmpty
            ? L10n.teleprompterExportDefaultFilename
            : script.title

        let fileName =
            "\(sanitizedFileName(title))-\(Self.exportTimestamp()).\(fileExtension)"

        return exportDirectory.appendingPathComponent(
            fileName
        )
    }

    private func sanitizedFileName(
        _ value: String
    ) -> String {

        let allowed =
            CharacterSet
                .alphanumerics
                .union(
                    CharacterSet(
                        charactersIn: " -_"
                    )
                )

        let scalars =
            value.unicodeScalars.map {
                allowed.contains($0)
                ? Character($0)
                : "-"
            }

        let collapsed =
            String(scalars)
                .replacingOccurrences(
                    of: "--",
                    with: "-"
                )
                .trimmingCharacters(
                    in: CharacterSet(
                        charactersIn: " -_"
                    )
                )

        return collapsed.isEmpty
        ? L10n.teleprompterExportDefaultFilename
        : String(
            collapsed.prefix(48)
        )
    }

    private static func exportTimestamp() -> String {

        let formatter =
            DateFormatter()

        formatter.dateFormat =
            "yyyyMMdd-HHmmss"

        return formatter.string(
            from: Date()
        )
    }

    private func pauseClock() {

        guard let start = activeSegmentStart else {
            return
        }

        accumulatedElapsed +=
            Date().timeIntervalSince(start)

        activeSegmentStart = nil
    }

    private func startProgressTimer() {

        progressTimer?.invalidate()

        progressTimer =
            Timer.scheduledTimer(
                withTimeInterval: 0.2,
                repeats: true
            ) { [weak self] _ in

                self?.emitProgress()
            }
    }

    private func emitProgress() {

        var elapsed = accumulatedElapsed

        if let start = activeSegmentStart {

            elapsed +=
                Date().timeIntervalSince(start)
        }

        let totalLength =
            max(
                1,
                speech.fullTextLengthUTF16
            )

        let progress =
            Double(currentReadOffsetUTF16)
            / Double(totalLength)

        onProgressTick?(
            elapsed,
            min(
                1,
                max(
                    0,
                    progress
                )
            )
        )
    }
}

extension PlayScriptViewModel:
    SpeechManagerDelegate {

    func speechManager(
        _ manager: SpeechManager,
        willSpeakCharacterRange range: NSRange,
        inFullText fullText: String
    ) {

        currentReadOffsetUTF16 =
            clampedOffset(
                range.location + range.length
            )

        TeleprompterPlaybackStore.saveLastReadOffset(
            currentReadOffsetUTF16,
            scriptId: script.id
        )

        onSpokenRange?(
            range,
            fullText
        )

        emitProgress()
    }

    func speechManagerDidFinish(
        _ manager: SpeechManager,
        completed: Bool
    ) {

        guard !isRestartingSpeech else {
            return
        }

        progressTimer?.invalidate()

        progressTimer = nil

        isPlaybackSessionActive = false

        pauseClock()

        if completed {

            currentReadOffsetUTF16 =
                speech.fullTextLengthUTF16

            TeleprompterPlaybackStore.clear(
                scriptId: script.id
            )
        }

        onPlayStateChanged?(false)

        onProgressTick?(
            accumulatedElapsed,
            completed ? 1 : 0
        )
    }
}
