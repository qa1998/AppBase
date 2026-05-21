//
//  AuthUseCase.swift
//  AppBase
//
//  Mẫu POST auth — chưa gắn Login (UI demo). Khi làm thật: Repo + Service + inject DI.
//

import Combine
import Foundation

final class AuthUseCase: AuthUseCaseProtocol {

    let isLoading = CurrentValueSubject<Bool, Never>(false)
    let didSucceed = PassthroughSubject<AuthResponse, Never>()
    let didFail = PassthroughSubject<TIOUserFacingError, Never>()

    private let api: APIServiceProtocol

    init(api: APIServiceProtocol = APIService.shared) {
        self.api = api
    }

    func login(email: String, password: String) {
        isLoading.send(true)
        let body = LoginRequest(email: email, password: password)
        api.post(.login, body: body) { [weak self] (result: Result<AuthResponse, APIError>) in
            self?.handle(result)
        }
    }

    func register(email: String, password: String) {
        isLoading.send(true)
        let body = RegisterRequest(email: email, password: password)
        api.post(.register, body: body) { [weak self] (result: Result<AuthResponse, APIError>) in
            self?.handle(result)
        }
    }

    private func handle(_ result: Result<AuthResponse, APIError>) {
        isLoading.send(false)
        switch result {
        case .success(let response):
            didSucceed.send(response)
        case .failure(let error):
            didFail.send(error.userFacing)
        }
    }
}
