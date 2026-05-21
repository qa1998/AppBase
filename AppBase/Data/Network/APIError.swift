//
//  APIError.swift
//  AppBase
//

import Foundation

enum APIError: Error {

    case invalidURL
    case encodingFailed(Error)
    case network(Error)
    case unauthorized
    case server(statusCode: Int, message: String?)
    case decoding(Error)
    case business(code: String, message: String?)
    case emptyData(message: String?)
    case unknown

    var userFacing: TIOUserFacingError {
        switch self {
        case .unauthorized:
            return TIOUserFacingError(
                message: L10n.Common.Error.message,
                showsRetry: false
            )
        case .server(_, let message):
            return TIOUserFacingError(message: message ?? L10n.Common.Error.message)
        case .business(_, let message), .emptyData(let message):
            return TIOUserFacingError(message: message ?? L10n.Common.Error.message)
        case .decoding:
            return TIOUserFacingError(message: L10n.Common.Error.message)
        case .encodingFailed, .network, .invalidURL, .unknown:
            return .generic
        }
    }
}
