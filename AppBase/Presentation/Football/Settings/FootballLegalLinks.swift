//
//  FootballLegalLinks.swift
//  AppBase
//

import Foundation

enum FootballLegalLinks {

    static var privacyPolicy: URL {
        url(forInfoKey: "PRIVACY_POLICY_URL", fallback: "https://example.com/privacy")
    }

    static var policy: URL {
        url(forInfoKey: "POLICY_URL", fallback: "https://example.com/policy")
    }

    static var appStoreReview: URL? {
        let id = Bundle.main.object(forInfoDictionaryKey: "APP_STORE_ID") as? String ?? ""
        guard !id.isEmpty, id != "0" else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(id)?action=write-review")
    }

    private static func url(forInfoKey key: String, fallback: String) -> URL {
        let string = Bundle.main.object(forInfoDictionaryKey: key) as? String
        return URL(string: string.flatMap { $0.isEmpty ? nil : $0 } ?? fallback)!
    }
}
