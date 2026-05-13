//
//  ElevenLabsCredentialStore.swift
//  AppBase
//

import Foundation
import Security

enum ElevenLabsCredentialStore {

    private static let service =
        "AppBase.ElevenLabs"

    private static let apiKeyAccount =
        "apiKey"

    static func saveAPIKey(
        _ apiKey: String
    ) throws {

        let trimmed =
            apiKey.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard let data =
                trimmed.data(
                    using: .utf8
                )
        else {
            return
        }

        try deleteAPIKeyIfNeeded()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: apiKeyAccount,
            kSecValueData as String: data
        ]

        let status =
            SecItemAdd(
                query as CFDictionary,
                nil
            )

        guard status == errSecSuccess else {
            throw KeychainError(status: status)
        }
    }

    static func apiKey() -> String? {

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: apiKeyAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?

        let status =
            SecItemCopyMatching(
                query as CFDictionary,
                &item
            )

        guard status == errSecSuccess,
              let data = item as? Data
        else {
            return nil
        }

        return String(
            data: data,
            encoding: .utf8
        )
    }

    static func deleteAPIKeyIfNeeded() throws {

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: apiKeyAccount
        ]

        let status =
            SecItemDelete(
                query as CFDictionary
            )

        guard status == errSecSuccess ||
                status == errSecItemNotFound
        else {
            throw KeychainError(status: status)
        }
    }
}

struct KeychainError: LocalizedError {
    let status: OSStatus

    var errorDescription: String? {
        L10n.keychainErrorStatus(
            status
        )
    }
}
