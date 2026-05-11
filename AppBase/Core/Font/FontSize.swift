//
//  FontSize.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit

enum FontSize {
    case text34
    case text28
    case text22
    case text17
    case text15
    case text13
    case text10
    
    case titles
    case buttons
    case links
    case inputs
    case subtitle
    
    case custon(CGFloat)
    
    var value: CGFloat {
        switch self {
        case .text34:
            return 34
        case .text28:
            return 28
        case .text22:
            return 22
        case .text17:
            return 17
        case .text15:
            return 15
        case .text13:
            return 13
        case .text10:
            return 10
        case .titles:
            return 17
        case .buttons:
            return 17
        case .links:
            return 17
        case .inputs:
            return 17
        case .subtitle:
            return 15
        case .custon(let value):
            return value
        }
    }
}

