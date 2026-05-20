//
//  Language.swift
//  AppBase
//
//  Created by QuangAnh on 7/5/26.
//

import Foundation

enum Language: String, CaseIterable {

    case english = "en"
    case vietnamese = "vi"
    case japanese = "ja"

    var localizedTitle: String {
        switch self {
        case .english:
            return L10n.Language.english
        case .vietnamese:
            return L10n.Language.vietnamese
        case .japanese:
            return L10n.Language.japanese
        }
    }
}
