// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Tạm biệt
  internal static var goodbye: String { return L10n.tr("Localizable", "Goodbye", fallback: "Tạm biệt") }
  /// Localizable.strings
  ///   AppBase
  /// 
  ///   Created by QuangAnh on 7/5/26.
  internal static var helllo: String { return L10n.tr("Localizable", "Helllo", fallback: "Xin chào") }
  /// Xin chào
  internal static var hi: String { return L10n.tr("Localizable", "Hi", fallback: "Xin chào") }
  internal enum Common {
    /// Cancel
    internal static var cancel: String { return L10n.tr("Localizable", "common.cancel", fallback: "Cancel") }
    /// OK
    internal static var ok: String { return L10n.tr("Localizable", "common.ok", fallback: "OK") }
  }
  internal enum Elevenlabs {
    internal enum Error {
      /// ElevenLabs did not return audio data.
      internal static var emptyAudioData: String { return L10n.tr("Localizable", "elevenlabs.error.empty_audio_data", fallback: "ElevenLabs did not return audio data.") }
      /// There is no text to synthesize.
      internal static var emptyText: String { return L10n.tr("Localizable", "elevenlabs.error.empty_text", fallback: "There is no text to synthesize.") }
      /// Invalid ElevenLabs URL.
      internal static var invalidUrl: String { return L10n.tr("Localizable", "elevenlabs.error.invalid_url", fallback: "Invalid ElevenLabs URL.") }
      /// ElevenLabs API key is not configured.
      internal static var missingApiKey: String { return L10n.tr("Localizable", "elevenlabs.error.missing_api_key", fallback: "ElevenLabs API key is not configured.") }
      /// ElevenLabs error %d.
      internal static func status(_ p1: Int) -> String {
        return L10n.tr("Localizable", "elevenlabs.error.status", p1, fallback: "ElevenLabs error %d.")
      }
      /// ElevenLabs error %d: %@
      internal static func statusMessage(_ p1: Int, _ p2: Any) -> String {
        return L10n.tr("Localizable", "elevenlabs.error.status_message", p1, String(describing: p2), fallback: "ElevenLabs error %d: %@")
      }
    }
  }
  internal enum Keychain {
    internal enum Error {
      /// Keychain error: %d
      internal static func status(_ p1: Int) -> String {
        return L10n.tr("Localizable", "keychain.error.status", p1, fallback: "Keychain error: %d")
      }
    }
  }
  internal enum Record {
    /// Done
    internal static var done: String { return L10n.tr("Localizable", "record.done", fallback: "Done") }
    /// (No content)
    internal static var emptyScript: String { return L10n.tr("Localizable", "record.empty_script", fallback: "(No content)") }
    /// Importing video...
    internal static var importProcessing: String { return L10n.tr("Localizable", "record.import_processing", fallback: "Importing video...") }
    /// Merging voice...
    internal static var processingVoice: String { return L10n.tr("Localizable", "record.processing_voice", fallback: "Merging voice...") }
    /// Speed: 100 wpm
    internal static var speedWpm: String { return L10n.tr("Localizable", "record.speed_wpm", fallback: "Speed: 100 wpm") }
    /// Trimming video...
    internal static var trimProcessing: String { return L10n.tr("Localizable", "record.trim_processing", fallback: "Trimming video...") }
    internal enum ImportVideo {
      /// Import video
      internal static var action: String { return L10n.tr("Localizable", "record.import_video.action", fallback: "Import video") }
      /// Could not import the selected video.
      internal static var error: String { return L10n.tr("Localizable", "record.import_video.error", fallback: "Could not import the selected video.") }
    }
    internal enum Pause {
      /// Pause recording
      internal static var accessibility: String { return L10n.tr("Localizable", "record.pause.accessibility", fallback: "Pause recording") }
    }
    internal enum ReadMode {
      /// Script reading mode
      internal static var accessibility: String { return L10n.tr("Localizable", "record.read_mode.accessibility", fallback: "Script reading mode") }
      /// Auto read
      internal static var auto: String { return L10n.tr("Localizable", "record.read_mode.auto", fallback: "Auto read") }
      /// Self read
      internal static var manual: String { return L10n.tr("Localizable", "record.read_mode.manual", fallback: "Self read") }
    }
    internal enum Resume {
      /// Resume recording
      internal static var accessibility: String { return L10n.tr("Localizable", "record.resume.accessibility", fallback: "Resume recording") }
    }
    internal enum Video {
      /// Record video
      internal static var action: String { return L10n.tr("Localizable", "record.video.action", fallback: "Record video") }
    }
    internal enum VideoError {
      /// Could Not Record Video
      internal static var title: String { return L10n.tr("Localizable", "record.video_error.title", fallback: "Could Not Record Video") }
    }
  }
  internal enum Speech {
    internal enum Export {
      internal enum Error {
        /// Exporting speech audio.
        internal static var alreadyExporting: String { return L10n.tr("Localizable", "speech.export.error.already_exporting", fallback: "Exporting speech audio.") }
        /// This script has no content to export.
        internal static var emptyText: String { return L10n.tr("Localizable", "speech.export.error.empty_text", fallback: "This script has no content to export.") }
        /// Could not read audio data from the system.
        internal static var unsupportedBuffer: String { return L10n.tr("Localizable", "speech.export.error.unsupported_buffer", fallback: "Could not read audio data from the system.") }
      }
    }
    internal enum Voice {
      /// %@ (%@)
      internal static func nameLanguageFormat(_ p1: Any, _ p2: Any) -> String {
        return L10n.tr("Localizable", "speech.voice.name_language_format", String(describing: p1), String(describing: p2), fallback: "%@ (%@)")
      }
      internal enum Quality {
        /// Default
        internal static var `default`: String { return L10n.tr("Localizable", "speech.voice.quality.default", fallback: "Default") }
        /// Enhanced
        internal static var enhanced: String { return L10n.tr("Localizable", "speech.voice.quality.enhanced", fallback: "Enhanced") }
        /// Premium
        internal static var premium: String { return L10n.tr("Localizable", "speech.voice.quality.premium", fallback: "Premium") }
      }
    }
  }
  internal enum Teleprompter {
    internal enum Export {
      /// Script
      internal static var defaultFilename: String { return L10n.tr("Localizable", "teleprompter.export.default_filename", fallback: "Script") }
      /// Teleprompter Exports
      internal static var directoryName: String { return L10n.tr("Localizable", "teleprompter.export.directory_name", fallback: "Teleprompter Exports") }
      internal enum Error {
        /// Could Not Export
        internal static var title: String { return L10n.tr("Localizable", "teleprompter.export.error.title", fallback: "Could Not Export") }
      }
    }
    internal enum Settings {
      /// Script reading settings
      internal static var accessibility: String { return L10n.tr("Localizable", "teleprompter.settings.accessibility", fallback: "Script reading settings") }
      /// Done
      internal static var done: String { return L10n.tr("Localizable", "teleprompter.settings.done", fallback: "Done") }
      /// %.0f pt
      internal static func fontPointFormat(_ p1: Float) -> String {
        return L10n.tr("Localizable", "teleprompter.settings.font_point_format", p1, fallback: "%.0f pt")
      }
      /// %.0f%%
      internal static func percentFormat(_ p1: Float) -> String {
        return L10n.tr("Localizable", "teleprompter.settings.percent_format", p1, fallback: "%.0f%%")
      }
      /// Reading Settings
      internal static var title: String { return L10n.tr("Localizable", "teleprompter.settings.title", fallback: "Reading Settings") }
      internal enum FontSize {
        /// Drag to change text size
        internal static var caption: String { return L10n.tr("Localizable", "teleprompter.settings.font_size.caption", fallback: "Drag to change text size") }
        /// Font Size
        internal static var title: String { return L10n.tr("Localizable", "teleprompter.settings.font_size.title", fallback: "Font Size") }
      }
      internal enum SpeechRate {
        /// Drag to make reading slower or faster
        internal static var caption: String { return L10n.tr("Localizable", "teleprompter.settings.speech_rate.caption", fallback: "Drag to make reading slower or faster") }
        /// Reading Speed
        internal static var title: String { return L10n.tr("Localizable", "teleprompter.settings.speech_rate.title", fallback: "Reading Speed") }
      }
    }
    internal enum Voice {
      /// Voice %@
      internal static func accessibility(_ p1: Any) -> String {
        return L10n.tr("Localizable", "teleprompter.voice.accessibility", String(describing: p1), fallback: "Voice %@")
      }
      /// Select voice
      internal static var selectAccessibility: String { return L10n.tr("Localizable", "teleprompter.voice.select_accessibility", fallback: "Select voice") }
      internal enum Empty {
        /// This device did not return any voices from Apple's voice library.
        internal static var message: String { return L10n.tr("Localizable", "teleprompter.voice.empty.message", fallback: "This device did not return any voices from Apple's voice library.") }
        /// No voices available
        internal static var title: String { return L10n.tr("Localizable", "teleprompter.voice.empty.title", fallback: "No voices available") }
      }
      internal enum Picker {
        /// This list comes from Apple's voice library on this device.
        internal static var message: String { return L10n.tr("Localizable", "teleprompter.voice.picker.message", fallback: "This list comes from Apple's voice library on this device.") }
        /// %@ · %@
        internal static func optionFormat(_ p1: Any, _ p2: Any) -> String {
          return L10n.tr("Localizable", "teleprompter.voice.picker.option_format", String(describing: p1), String(describing: p2), fallback: "%@ · %@")
        }
        /// Current - %@ · %@
        internal static func selectedFormat(_ p1: Any, _ p2: Any) -> String {
          return L10n.tr("Localizable", "teleprompter.voice.picker.selected_format", String(describing: p1), String(describing: p2), fallback: "Current - %@ · %@")
        }
        /// Select Voice
        internal static var title: String { return L10n.tr("Localizable", "teleprompter.voice.picker.title", fallback: "Select Voice") }
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = TranslationService.shared.lookupTranslation(key, table, value)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

