//
//  AuthModels.swift
//  AppBase
//

import Foundation

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable {
    let email: String
    let password: String
}

struct AuthResponse: Decodable, Equatable {
    let token: String
}
