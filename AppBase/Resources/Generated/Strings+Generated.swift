// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum App {
    /// App
    internal static var name: String { return L10n.tr("Localizable", "app.name", fallback: "MC Teleprompter") }
    internal enum Tagline {
      /// Focus on your content.
      internal static var focus: String { return L10n.tr("Localizable", "app.tagline.focus", fallback: "Focus on your content.") }
      /// Easy teleprompter.
      internal static var prompting: String { return L10n.tr("Localizable", "app.tagline.prompting", fallback: "Easy teleprompter.") }
    }
  }
  internal enum Common {
    /// Cancel
    internal static var cancel: String { return L10n.tr("Localizable", "common.cancel", fallback: "Cancel") }
    /// Common
    internal static var loading: String { return L10n.tr("Localizable", "common.loading", fallback: "Loading...") }
  }
  internal enum Language {
    /// Language
    internal static var english: String { return L10n.tr("Localizable", "language.english", fallback: "English") }
    /// Japanese
    internal static var japanese: String { return L10n.tr("Localizable", "language.japanese", fallback: "Japanese") }
    /// Vietnamese
    internal static var vietnamese: String { return L10n.tr("Localizable", "language.vietnamese", fallback: "Vietnamese") }
  }
  internal enum Library {
    /// Library
    internal static var title: String { return L10n.tr("Localizable", "library.title", fallback: "Library") }
    internal enum Button {
      /// Shimmer subtitle only
      internal static var shimmerSubtitle: String { return L10n.tr("Localizable", "library.button.shimmerSubtitle", fallback: "Shimmer subtitle only") }
      /// Shimmer title only
      internal static var shimmerTitle: String { return L10n.tr("Localizable", "library.button.shimmerTitle", fallback: "Shimmer title only") }
      /// Test loading (screen)
      internal static var testScreen: String { return L10n.tr("Localizable", "library.button.testScreen", fallback: "Test loading (screen)") }
    }
    internal enum Loaded {
      /// Fake API · %@
      internal static func subtitle(_ p1: Any) -> String {
        return L10n.tr("Localizable", "library.loaded.subtitle", String(describing: p1), fallback: "Fake API · %@")
      }
      /// Library loaded
      internal static var title: String { return L10n.tr("Localizable", "library.loaded.title", fallback: "Library loaded") }
    }
    internal enum Subtitle {
      /// Tap a button to test shimmer
      internal static var hint: String { return L10n.tr("Localizable", "library.subtitle.hint", fallback: "Tap a button to test shimmer") }
    }
  }
  internal enum Login {
    /// Login
    internal static var title: String { return L10n.tr("Localizable", "login.title", fallback: "Login") }
    internal enum Register {
      /// Register
      internal static var title: String { return L10n.tr("Localizable", "login.register.title", fallback: "Register") }
    }
  }
  internal enum Maintain {
    /// We will be back soon.
    internal static var message: String { return L10n.tr("Localizable", "maintain.message", fallback: "We will be back soon.") }
    /// Maintenance
    internal static var title: String { return L10n.tr("Localizable", "maintain.title", fallback: "Maintenance") }
  }
  internal enum Onboard {
    /// Onboarding
    internal static var start: String { return L10n.tr("Localizable", "onboard.start", fallback: "Get Started") }
  }
  internal enum Settings {
    /// Appearance
    internal static var appearance: String { return L10n.tr("Localizable", "settings.appearance", fallback: "Appearance") }
    /// App Version
    internal static var appVersion: String { return L10n.tr("Localizable", "settings.appVersion", fallback: "App Version") }
    /// Backup & Sync
    internal static var backup: String { return L10n.tr("Localizable", "settings.backup", fallback: "Backup & Sync") }
    /// Help & Support
    internal static var help: String { return L10n.tr("Localizable", "settings.help", fallback: "Help & Support") }
    /// Language
    internal static var language: String { return L10n.tr("Localizable", "settings.language", fallback: "Language") }
    /// Notifications
    internal static var notifications: String { return L10n.tr("Localizable", "settings.notifications", fallback: "Notifications") }
    /// Privacy
    internal static var privacy: String { return L10n.tr("Localizable", "settings.privacy", fallback: "Privacy") }
    /// Rate Us
    internal static var rateUs: String { return L10n.tr("Localizable", "settings.rateUs", fallback: "Rate Us") }
    /// Security
    internal static var security: String { return L10n.tr("Localizable", "settings.security", fallback: "Security") }
    /// Storage
    internal static var storage: String { return L10n.tr("Localizable", "settings.storage", fallback: "Storage") }
    /// Terms of Service
    internal static var terms: String { return L10n.tr("Localizable", "settings.terms", fallback: "Terms of Service") }
    /// Theme
    internal static var theme: String { return L10n.tr("Localizable", "settings.theme", fallback: "Theme") }
    /// Settings
    internal static var title: String { return L10n.tr("Localizable", "settings.title", fallback: "Settings") }
    internal enum AppVersion {
      /// 1.2.3 (123)
      internal static var value: String { return L10n.tr("Localizable", "settings.appVersion.value", fallback: "1.2.3 (123)") }
    }
    internal enum Section {
      /// ABOUT
      internal static var about: String { return L10n.tr("Localizable", "settings.section.about", fallback: "ABOUT") }
      /// GENERAL
      internal static var general: String { return L10n.tr("Localizable", "settings.section.general", fallback: "GENERAL") }
      /// PREFERENCES
      internal static var preferences: String { return L10n.tr("Localizable", "settings.section.preferences", fallback: "PREFERENCES") }
    }
    internal enum Theme {
      /// Dark
      internal static var dark: String { return L10n.tr("Localizable", "settings.theme.dark", fallback: "Dark") }
      /// Light
      internal static var light: String { return L10n.tr("Localizable", "settings.theme.light", fallback: "Light") }
      /// System
      internal static var system: String { return L10n.tr("Localizable", "settings.theme.system", fallback: "System") }
    }
  }
  internal enum Tab {
    /// Tab bar
    internal static var home: String { return L10n.tr("Localizable", "tab.home", fallback: "Home") }
    /// Library
    internal static var library: String { return L10n.tr("Localizable", "tab.library", fallback: "Library") }
    /// Record
    internal static var record: String { return L10n.tr("Localizable", "tab.record", fallback: "Record") }
    /// Scripts
    internal static var scripts: String { return L10n.tr("Localizable", "tab.scripts", fallback: "Scripts") }
    /// Settings
    internal static var settings: String { return L10n.tr("Localizable", "tab.settings", fallback: "Settings") }
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

