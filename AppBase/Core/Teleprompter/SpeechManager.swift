//
//  SpeechManager.swift
//  AppBase
//

import AVFoundation
import Foundation

protocol SpeechManagerDelegate: AnyObject {
    /// Range trong **fullText** (UTF-16) sắp được đọc (thường theo từ/cụm).
    func speechManager(_ manager: SpeechManager, willSpeakCharacterRange range: NSRange, inFullText fullText: String)
    func speechManagerDidFinish(_ manager: SpeechManager, completed: Bool)
}

/// Bọc `AVSpeechSynthesizer`, tối ưu tiếng Việt và map range về full script.
final class SpeechManager: NSObject {

    struct Configuration: Equatable {
        /// 0.0 ... 1.0 — mặc định hệ thống ~0.5
        var rate: Float = 0.48
        var pitchMultiplier: Float = 1.0
        var volume: Float = 1.0
    }

    enum ExportError: LocalizedError {
        case alreadyExporting
        case emptyText
        case unsupportedBuffer

        var errorDescription: String? {
            switch self {
            case .alreadyExporting:
                return L10n.speechExportErrorAlreadyExporting
            case .emptyText:
                return L10n.speechExportErrorEmptyText
            case .unsupportedBuffer:
                return L10n.speechExportErrorUnsupportedBuffer
            }
        }
    }

    weak var delegate: SpeechManagerDelegate?

    private let synthesizer = AVSpeechSynthesizer()
    private var exportSynthesizer: AVSpeechSynthesizer?
    private(set) var fullText: String = ""
    /// UTF-16 offset: nội dung utterance là fullText từ vị trí này.
    private var utteranceStartUTF16: Int = 0
    private var suppressCancelCallback = false

    var configuration = Configuration()
    var voice: AVSpeechSynthesisVoice? = AVSpeechSynthesisVoice(language: "vi-VN")

    private(set) var isSpeaking: Bool = false
    private(set) var isPaused: Bool = false

    /// Đang có phiên đọc (đang nói hoặc đang pause giữa chừng).
    var isUtteranceActive: Bool {
        synthesizer.isSpeaking || isPaused
    }

    /// Đang phát âm thanh (không gồm trạng thái pause).
    var isSynthesizerSpeaking: Bool {
        synthesizer.isSpeaking
    }

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    static func availableAppleVoices(
        preferredLanguage: String = "vi-VN"
    ) -> [AVSpeechSynthesisVoice] {

        let currentLanguage =
            Locale.current.languageCode ?? ""

        return AVSpeechSynthesisVoice
            .speechVoices()
            .sorted {
                lhs,
                rhs in

                let lhsPriority =
                    voicePriority(
                        lhs,
                        preferredLanguage: preferredLanguage,
                        currentLanguage: currentLanguage
                    )

                let rhsPriority =
                    voicePriority(
                        rhs,
                        preferredLanguage: preferredLanguage,
                        currentLanguage: currentLanguage
                    )

                if lhsPriority != rhsPriority {
                    return lhsPriority < rhsPriority
                }

                if lhs.language != rhs.language {
                    return lhs.language < rhs.language
                }

                return lhs.name < rhs.name
            }
    }

    static func appleVoice(
        identifier: String
    ) -> AVSpeechSynthesisVoice? {

        AVSpeechSynthesisVoice(
            identifier: identifier
        )
    }

    func setText(_ text: String) {
        guard fullText != text else { return }
        stop()
        fullText = text
        utteranceStartUTF16 = 0
    }

    var fullTextLengthUTF16: Int {
        (fullText as NSString).length
    }

    /// Bắt đầu / tiếp tục đọc từ offset UTF-16.
    func speak(from utf16Offset: Int = 0) {
        stop(notifyDelegate: false)
        guard !fullText.isEmpty else {
            delegate?.speechManagerDidFinish(self, completed: true)
            return
        }
        let clamped = max(0, min(utf16Offset, (fullText as NSString).length))
        utteranceStartUTF16 = clamped
        let nsFull = fullText as NSString
        let substring = nsFull.substring(from: clamped)
        guard !substring.isEmpty else {
            delegate?.speechManagerDidFinish(self, completed: true)
            return
        }

        let utterance =
            makeUtterance(
                string: substring
            )

        isSpeaking = true
        isPaused = false
        synthesizer.speak(utterance)
    }

    func exportSpeech(
        to fileURL: URL,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {

        guard exportSynthesizer == nil else {
            completion(
                .failure(
                    ExportError.alreadyExporting
                )
            )
            return
        }

        let exportText =
            fullText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !exportText.isEmpty else {
            completion(
                .failure(
                    ExportError.emptyText
                )
            )
            return
        }

        do {

            if FileManager.default.fileExists(
                atPath: fileURL.path
            ) {

                try FileManager.default.removeItem(
                    at: fileURL
                )
            }

        } catch {

            completion(
                .failure(error)
            )
            return
        }

        let exportSynthesizer =
            AVSpeechSynthesizer()

        self.exportSynthesizer =
            exportSynthesizer

        let utterance =
            makeUtterance(
                string: exportText
            )

        var audioFile: AVAudioFile?
        var didFinish = false

        let finish: (Result<URL, Error>) -> Void = {
            [weak self]
            result in

            guard !didFinish else {
                return
            }

            didFinish = true
            audioFile = nil
            self?.exportSynthesizer = nil

            DispatchQueue.main.async {
                completion(result)
            }
        }

        exportSynthesizer.write(
            utterance
        ) {
            buffer in

            guard !didFinish else {
                return
            }

            guard let pcmBuffer =
                    buffer as? AVAudioPCMBuffer
            else {

                exportSynthesizer.stopSpeaking(
                    at: .immediate
                )

                finish(
                    .failure(
                        ExportError.unsupportedBuffer
                    )
                )
                return
            }

            guard pcmBuffer.frameLength > 0 else {

                finish(
                    .success(fileURL)
                )
                return
            }

            do {

                if audioFile == nil {

                    audioFile =
                        try AVAudioFile(
                            forWriting: fileURL,
                            settings: pcmBuffer.format.settings
                        )
                }

                try audioFile?.write(
                    from: pcmBuffer
                )

            } catch {

                exportSynthesizer.stopSpeaking(
                    at: .immediate
                )

                finish(
                    .failure(error)
                )
            }
        }
    }

    func togglePause() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .immediate)
            isPaused = true
            isSpeaking = false
        } else if isPaused {
            synthesizer.continueSpeaking()
            isPaused = false
            isSpeaking = true
        }
    }

    func pause() {
        guard synthesizer.isSpeaking else { return }
        synthesizer.pauseSpeaking(at: .immediate)
        isPaused = true
    }

    func resume() {
        guard isPaused else { return }
        synthesizer.continueSpeaking()
        isPaused = false
    }

    func stop() {
        stop(notifyDelegate: true)
    }

    private func stop(notifyDelegate: Bool) {
        if synthesizer.isSpeaking || isPaused {
            suppressCancelCallback = !notifyDelegate
        }

        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        isPaused = false
    }

    /// Cập nhật cấu hình cho lần `speak` tiếp theo (không làm gián đoạn nếu đang đọc).
    func applyConfigurationToCurrentUtterance() {
        // AVSpeechUtterance không đổi sau khi queue — chỉ áp dụng khi speak lại.
    }

    private func makeUtterance(
        string: String
    ) -> AVSpeechUtterance {

        let utterance =
            AVSpeechUtterance(
                string: string
            )

        utterance.voice =
            voice
            ?? AVSpeechSynthesisVoice(
                language: "vi-VN"
            )

        utterance.rate =
            configuration.rate

        utterance.pitchMultiplier =
            configuration.pitchMultiplier

        utterance.volume =
            configuration.volume

        return utterance
    }

    private func mapToFullTextRange(_ rangeInUtterance: NSRange) -> NSRange {
        NSRange(location: rangeInUtterance.location + utteranceStartUTF16, length: rangeInUtterance.length)
    }

    private static func voicePriority(
        _ voice: AVSpeechSynthesisVoice,
        preferredLanguage: String,
        currentLanguage: String
    ) -> Int {

        if voice.language == preferredLanguage {
            return 0
        }

        if voice.language.hasPrefix("vi") {
            return 1
        }

        if !currentLanguage.isEmpty &&
            voice.language.hasPrefix(currentLanguage) {

            return 2
        }

        return 3
    }
}

extension SpeechManager: AVSpeechSynthesizerDelegate {

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isSpeaking = true
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let fullRange = mapToFullTextRange(characterRange)
        delegate?.speechManager(self, willSpeakCharacterRange: fullRange, inFullText: fullText)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
        isPaused = false
        delegate?.speechManagerDidFinish(self, completed: true)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
        isPaused = false
        let shouldNotify = !suppressCancelCallback
        suppressCancelCallback = false
        guard shouldNotify else { return }
        delegate?.speechManagerDidFinish(self, completed: false)
    }
}
