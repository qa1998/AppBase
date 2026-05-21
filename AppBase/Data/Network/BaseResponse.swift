//
//  BaseResponse.swift
//  AppBase
//

import Foundation

/// Envelope JSON chuẩn: `{ "code", "data", "message" }`.
struct BaseResponse<T: Decodable>: Decodable {

    var code: String?
    var data: T?
    var message: String?
    /// VietQR và một số API dùng `desc` thay `message`.
    var desc: String?

    var statusMessage: String? { message ?? desc }
}

// MARK: - Unwrap

extension BaseResponse {

    /// Mã coi là thành công — chỉnh theo contract backend.
    static var defaultSuccessCodes: Set<String> { ["0", "00", "200", "success", "SUCCESS"] }

    var isSuccess: Bool {
        guard let code else { return data != nil }
        return Self.defaultSuccessCodes.contains(code)
            || Self.defaultSuccessCodes.contains(code.lowercased())
    }

    /// Trả `data` khi success; lỗi business khi `code` fail hoặc thiếu `data`.
    func unwrap(successCodes: Set<String> = BaseResponse.defaultSuccessCodes) -> Result<T, APIError> {
        if let code, !successCodes.contains(code), !successCodes.contains(code.lowercased()) {
            return .failure(.business(code: code, message: statusMessage))
        }
        guard let data else {
            return .failure(.emptyData(message: statusMessage))
        }
        return .success(data)
    }
}
