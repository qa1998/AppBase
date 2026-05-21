//
//  APIEndpoint.swift
//  AppBase
//

import Foundation

enum APIEndpoint {

    case login
    case register
    case homeItems(page: Int)
    case vietQRBanks

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .register:
            return "/auth/register"
        case let .homeItems(page):
            return "/home/items?page=\(page)"
        case .vietQRBanks:
            return "/v2/banks"
        }
    }

    var urlString: String {
        switch self {
        case .vietQRBanks:
            return APIConfiguration.vietQRBaseURL + path
        default:
            return APIConfiguration.baseURL + path
        }
    }
}
