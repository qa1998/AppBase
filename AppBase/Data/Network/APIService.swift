//
//  APIService.swift
//  AppBase
//

import Alamofire
import Foundation

final class APIService {

    static let shared = APIService()

    private let session: Session

    private init() {
        session = Session(
            configuration: {
                let config = URLSessionConfiguration.default
                config.timeoutIntervalForRequest = APIConfiguration.defaultTimeout
                return config
            }()
        )
    }

    private var defaultHeaders: HTTPHeaders {
        var headers = HTTPHeaders.default
        let token = AppData.shared.token
        if !token.isEmpty {
            headers.add(.authorization(bearerToken: token))
        }
        headers.add(.accept("application/json"))
        return headers
    }

    // MARK: - GET / query

    func get<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        performRequest(
            url: endpoint.urlString,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: mergeHeaders(headers),
            completion: completion
        )
    }

    // MARK: - JSON body (POST, PUT, PATCH, …)

    func post<T: Decodable, Body: Encodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod = .post,
        body: Body,
        headers: HTTPHeaders? = nil,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        let url = endpoint.urlString
        guard URL(string: url) != nil else {
            completion(.failure(.invalidURL))
            return
        }

        var allHeaders = mergeHeaders(headers)
        allHeaders.add(.contentType("application/json"))

        do {
            let data = try JSONEncoder().encode(body)
            session.request(
                url,
                method: method,
                headers: allHeaders,
                requestModifier: { $0.httpBody = data }
            )
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.self) { [weak self] response in
                self?.handleResponse(response, completion: completion)
            }
        } catch {
            completion(.failure(.encodingFailed(error)))
        }
    }

    // MARK: - Private

    private func performRequest<T: Decodable>(
        url: String,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        guard URL(string: url) != nil else {
            completion(.failure(.invalidURL))
            return
        }

        session.request(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
        )
        .validate(statusCode: 200..<300)
        #if DEBUG
        .cURLDescription { curl in
            print("🌐 CURL:\n\(curl)")
        }
        #endif
        .responseDecodable(of: T.self) { [weak self] response in
            self?.handleResponse(response, completion: completion)
        }
    }

    private func handleResponse<T: Decodable>(
        _ response: DataResponse<T, AFError>,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        switch response.result {
        case .success(let value):
            completion(.success(value))
        case .failure(let afError):
            completion(.failure(mapAFError(afError, response: response.response)))
        }
    }

    private func mapAFError(_ error: AFError, response: HTTPURLResponse?) -> APIError {
        if response?.statusCode == 401 {
            return .unauthorized
        }
        if let status = response?.statusCode, status >= 400 {
            return .server(statusCode: status, message: error.localizedDescription)
        }
        if case .responseSerializationFailed(let reason) = error,
           case .decodingFailed(let decodeError) = reason {
            return .decoding(decodeError)
        }
        return .network(error)
    }

    private func mergeHeaders(_ extra: HTTPHeaders?) -> HTTPHeaders {
        var headers = defaultHeaders
        extra?.forEach { headers.add($0) }
        return headers
    }
}
