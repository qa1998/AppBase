//
//  L10n+TeleprompterAliases.swift
//  AppBase
//

import CoreGraphics
import Foundation

extension L10n {

    private static func localize(
        _ key: String,
        fallback: String
    ) -> String {

        TranslationService.shared.lookupTranslation(
            key,
            "Localizable",
            fallback
        )
    }

    static var commonCancel: String { Common.cancel }
    static var commonOK: String { Common.ok }

    static var elevenlabsErrorMissingAPIKey: String { Elevenlabs.Error.missingApiKey }
    static var elevenlabsErrorInvalidURL: String { Elevenlabs.Error.invalidUrl }
    static var elevenlabsErrorEmptyText: String { Elevenlabs.Error.emptyText }
    static var elevenlabsErrorEmptyAudioData: String { Elevenlabs.Error.emptyAudioData }

    static func elevenlabsErrorStatus(
        _ statusCode: Int
    ) -> String {

        Elevenlabs.Error.status(
            statusCode
        )
    }

    static func elevenlabsErrorStatusMessage(
        _ statusCode: Int,
        _ message: String
    ) -> String {

        Elevenlabs.Error.statusMessage(
            statusCode,
            message
        )
    }

    static func keychainErrorStatus(
        _ status: Int32
    ) -> String {

        Keychain.Error.status(
            Int(status)
        )
    }

    static var speechExportErrorAlreadyExporting: String {
        Speech.Export.Error.alreadyExporting
    }

    static var speechExportErrorEmptyText: String {
        Speech.Export.Error.emptyText
    }

    static var speechExportErrorUnsupportedBuffer: String {
        Speech.Export.Error.unsupportedBuffer
    }

    static func speechVoiceNameLanguageFormat(
        _ name: String,
        _ language: String
    ) -> String {

        Speech.Voice.nameLanguageFormat(
            name,
            language
        )
    }

    static var speechVoiceQualityPremium: String {
        Speech.Voice.Quality.premium
    }

    static var speechVoiceQualityEnhanced: String {
        Speech.Voice.Quality.enhanced
    }

    static var speechVoiceQualityDefault: String {
        Speech.Voice.Quality.default
    }

    static var teleprompterExportDefaultFilename: String {
        Teleprompter.Export.defaultFilename
    }

    static var teleprompterExportDirectoryName: String {
        Teleprompter.Export.directoryName
    }

    static var teleprompterExportErrorTitle: String {
        Teleprompter.Export.Error.title
    }

    static var teleprompterSettingsAccessibility: String {
        Teleprompter.Settings.accessibility
    }

    static var teleprompterSettingsTitle: String {
        Teleprompter.Settings.title
    }

    static var teleprompterSettingsDone: String {
        Teleprompter.Settings.done
    }

    static var teleprompterSettingsSpeechRateTitle: String {
        Teleprompter.Settings.SpeechRate.title
    }

    static var teleprompterSettingsSpeechRateCaption: String {
        Teleprompter.Settings.SpeechRate.caption
    }

    static var teleprompterSettingsFontSizeTitle: String {
        Teleprompter.Settings.FontSize.title
    }

    static var teleprompterSettingsFontSizeCaption: String {
        Teleprompter.Settings.FontSize.caption
    }

    static func teleprompterSettingsPercentFormat(
        _ value: Float
    ) -> String {

        Teleprompter.Settings.percentFormat(
            value
        )
    }

    static func teleprompterSettingsFontPointFormat(
        _ value: CGFloat
    ) -> String {

        Teleprompter.Settings.fontPointFormat(
            Float(value)
        )
    }

    static func teleprompterVoiceAccessibility(
        _ voiceName: String
    ) -> String {

        Teleprompter.Voice.accessibility(
            voiceName
        )
    }

    static var teleprompterVoiceSelectAccessibility: String {
        Teleprompter.Voice.selectAccessibility
    }

    static var teleprompterVoiceEmptyTitle: String {
        Teleprompter.Voice.Empty.title
    }

    static var teleprompterVoiceEmptyMessage: String {
        Teleprompter.Voice.Empty.message
    }

    static var teleprompterVoicePickerTitle: String {
        Teleprompter.Voice.Picker.title
    }

    static var teleprompterVoicePickerMessage: String {
        Teleprompter.Voice.Picker.message
    }

    static func teleprompterVoicePickerSelectedFormat(
        _ title: String,
        _ subtitle: String
    ) -> String {

        Teleprompter.Voice.Picker.selectedFormat(
            title,
            subtitle
        )
    }

    static func teleprompterVoicePickerOptionFormat(
        _ title: String,
        _ subtitle: String
    ) -> String {

        Teleprompter.Voice.Picker.optionFormat(
            title,
            subtitle
        )
    }

    static var recordReadModeManual: String {
        localize(
            "record.read_mode.manual",
            fallback: "Tự đọc"
        )
    }

    static var recordReadModeAuto: String {
        localize(
            "record.read_mode.auto",
            fallback: "Auto đọc"
        )
    }

    static var recordReadModeAccessibility: String {
        localize(
            "record.read_mode.accessibility",
            fallback: "Chế độ đọc script"
        )
    }

    static var recordDone: String {
        localize(
            "record.done",
            fallback: "Xong"
        )
    }

    static var recordVideoAction: String {
        localize(
            "record.video.action",
            fallback: "Quay video"
        )
    }

    static var recordImportVideoAction: String {
        localize(
            "record.import_video.action",
            fallback: "Import video"
        )
    }

    static var recordProcessingVoice: String {
        localize(
            "record.processing_voice",
            fallback: "Đang ghép giọng đọc..."
        )
    }

    static var recordImportProcessing: String {
        localize(
            "record.import_processing",
            fallback: "Đang import video..."
        )
    }

    static var recordTrimProcessing: String {
        localize(
            "record.trim_processing",
            fallback: "Đang trim video..."
        )
    }

    static var recordImportVideoError: String {
        localize(
            "record.import_video.error",
            fallback: "Không thể import video đã chọn."
        )
    }

    static var recordPauseAccessibility: String {
        localize(
            "record.pause.accessibility",
            fallback: "Tạm dừng quay"
        )
    }

    static var recordResumeAccessibility: String {
        localize(
            "record.resume.accessibility",
            fallback: "Tiếp tục quay"
        )
    }

    static var recordSpeedWPM: String {
        localize(
            "record.speed_wpm",
            fallback: "Tốc độ: 100 wpm"
        )
    }

    static var recordEmptyScript: String {
        localize(
            "record.empty_script",
            fallback: "(Chưa có nội dung)"
        )
    }

    static var recordVideoErrorTitle: String {
        localize(
            "record.video_error.title",
            fallback: "Không thể quay video"
        )
    }
}
