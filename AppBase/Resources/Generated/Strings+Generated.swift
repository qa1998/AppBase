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
    /// OK
    internal static var ok: String { return L10n.tr("Localizable", "common.ok", fallback: "OK") }
    /// Retry
    internal static var retry: String { return L10n.tr("Localizable", "common.retry", fallback: "Retry") }
    internal enum Error {
      /// Something went wrong. Please try again.
      internal static var message: String { return L10n.tr("Localizable", "common.error.message", fallback: "Something went wrong. Please try again.") }
      /// Error
      internal static var title: String { return L10n.tr("Localizable", "common.error.title", fallback: "Error") }
    }
    internal enum Success {
      /// Success
      internal static var title: String { return L10n.tr("Localizable", "common.success.title", fallback: "Success") }
    }
  }
  internal enum Home {
    internal enum Nav {
      /// Home
      internal static var testEmpty: String { return L10n.tr("Localizable", "home.nav.testEmpty", fallback: "Empty") }
      /// Error
      internal static var testError: String { return L10n.tr("Localizable", "home.nav.testError", fallback: "Error") }
      /// Toast−
      internal static var testToastError: String { return L10n.tr("Localizable", "home.nav.testToastError", fallback: "Toast−") }
      /// Toast+
      internal static var testToastSuccess: String { return L10n.tr("Localizable", "home.nav.testToastSuccess", fallback: "Toast+") }
    }
    internal enum Toast {
      /// This is a demo error toast (SwiftEntryKit).
      internal static var testError: String { return L10n.tr("Localizable", "home.toast.testError", fallback: "This is a demo error toast (SwiftEntryKit).") }
      /// Demo success toast — banks loaded.
      internal static var testSuccess: String { return L10n.tr("Localizable", "home.toast.testSuccess", fallback: "Demo success toast — banks loaded.") }
    }
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
  internal enum List {
    internal enum Empty {
      /// Pull down to refresh.
      internal static var message: String { return L10n.tr("Localizable", "list.empty.message", fallback: "Pull down to refresh.") }
      /// List empty / error
      internal static var title: String { return L10n.tr("Localizable", "list.empty.title", fallback: "No items yet") }
    }
    internal enum Error {
      /// Check your connection and try again.
      internal static var message: String { return L10n.tr("Localizable", "list.error.message", fallback: "Check your connection and try again.") }
      /// Couldn't load
      internal static var title: String { return L10n.tr("Localizable", "list.error.title", fallback: "Couldn't load") }
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
  internal enum Scripts {
    internal enum Ads {
      /// Failed: %@
      internal static func failed(_ p1: Any) -> String {
        return L10n.tr("Localizable", "scripts.ads.failed", String(describing: p1), fallback: "Failed: %@")
      }
      /// Hide banner
      internal static var hideBanner: String { return L10n.tr("Localizable", "scripts.ads.hideBanner", fallback: "Hide banner") }
      /// Scripts — Ads demo
      internal static var hint: String { return L10n.tr("Localizable", "scripts.ads.hint", fallback: "Load then show each ad type (AdMob test IDs).") }
      /// Load app open
      internal static var loadAppOpen: String { return L10n.tr("Localizable", "scripts.ads.loadAppOpen", fallback: "Load app open") }
      /// Load banner
      internal static var loadBanner: String { return L10n.tr("Localizable", "scripts.ads.loadBanner", fallback: "Load banner") }
      /// Loading…
      internal static var loading: String { return L10n.tr("Localizable", "scripts.ads.loading", fallback: "Loading…") }
      /// Load interstitial
      internal static var loadInterstitial: String { return L10n.tr("Localizable", "scripts.ads.loadInterstitial", fallback: "Load interstitial") }
      /// Load rewarded
      internal static var loadRewarded: String { return L10n.tr("Localizable", "scripts.ads.loadRewarded", fallback: "Load rewarded") }
      /// Reward: %d %@
      internal static func reward(_ p1: Int, _ p2: Any) -> String {
        return L10n.tr("Localizable", "scripts.ads.reward", p1, String(describing: p2), fallback: "Reward: %d %@")
      }
      /// Show app open
      internal static var showAppOpen: String { return L10n.tr("Localizable", "scripts.ads.showAppOpen", fallback: "Show app open") }
      /// Show banner
      internal static var showBanner: String { return L10n.tr("Localizable", "scripts.ads.showBanner", fallback: "Show banner") }
      /// Show interstitial
      internal static var showInterstitial: String { return L10n.tr("Localizable", "scripts.ads.showInterstitial", fallback: "Show interstitial") }
      /// Show rewarded
      internal static var showRewarded: String { return L10n.tr("Localizable", "scripts.ads.showRewarded", fallback: "Show rewarded") }
      /// Status: %@
      internal static func status(_ p1: Any) -> String {
        return L10n.tr("Localizable", "scripts.ads.status", String(describing: p1), fallback: "Status: %@")
      }
      /// Success: %@
      internal static func success(_ p1: Any) -> String {
        return L10n.tr("Localizable", "scripts.ads.success", String(describing: p1), fallback: "Success: %@")
      }
    }
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

