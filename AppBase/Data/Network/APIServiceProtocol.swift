//
//  APIServiceProtocol.swift
//  AppBase
//

import Alamofire
import Foundation

protocol APIServiceProtocol: AnyObject {

    func get<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?,
        completion: @escaping (Result<T, APIError>) -> Void
    )

    func post<T: Decodable, Body: Encodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod,
        body: Body,
        headers: HTTPHeaders?,
        completion: @escaping (Result<T, APIError>) -> Void
    )
}

extension APIServiceProtocol {

    func get<T: Decodable>(
        _ endpoint: APIEndpoint,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        get(
            endpoint,
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: nil,
            completion: completion
        )
    }

    func post<T: Decodable, Body: Encodable>(
        _ endpoint: APIEndpoint,
        body: Body,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        post(
            endpoint,
            method: .post,
            body: body,
            headers: nil,
            completion: completion
        )
    }
}

extension APIService: APIServiceProtocol {}
