//
//  TranslationService.swift
//  AppBase
//
//  Created by QuangAnh on 7/5/26.
//


import Foundation

final class TranslationService {

    static let shared = TranslationService()

    private init() {}

    func lookupTranslation(
        _ key: String,
        _ table: String = "Localizable",
        _ fallback: String = ""
    ) -> String {

        let language =
        LocalizationService.shared.currentLanguage

        guard let path = Bundle.main.path(
            forResource: language.rawValue,
            ofType: "lproj"
        ),
        let bundle = Bundle(path: path) else {

            return fallback
        }

        return bundle.localizedString(
            forKey: key,
            value: fallback,
            table: table
        )
    }
}
