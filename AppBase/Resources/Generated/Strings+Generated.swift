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

