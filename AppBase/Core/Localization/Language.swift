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

    var title: String {

        switch self {

        case .english:
            return "English"

        case .vietnamese:
            return "Tiếng Việt"

        case .japanese:
            return "日本語"
        }
    }
}

