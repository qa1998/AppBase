//
//  Bank.swift
//  AppBase
//

import Foundation

/// Ngân hàng từ [VietQR API](https://api.vietqr.io/v2/banks).
struct Bank: Decodable, Equatable {

    let id: Int
    let name: String
    let code: String
    let bin: String
    let shortName: String
    let logo: String?

    var logoURL: URL? {
        guard let logo, !logo.isEmpty else { return nil }
        return URL(string: logo)
    }

    var subtitle: String {
        "\(code) · BIN \(bin)"
    }
}
