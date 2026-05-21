//
//  APIConfiguration.swift
//  AppBase
//

import Foundation

enum APIConfiguration {

    /// Base URL app backend — đổi khi có server thật (login/homeItems placeholder).
    static var baseURL: String {
        "https://api.example.com"
    }

    static var defaultTimeout: TimeInterval { 30 }

    /// [VietQR Open API](https://api.vietqr.io/v2/banks)
    static let vietQRBaseURL = "https://api.vietqr.io"
}
