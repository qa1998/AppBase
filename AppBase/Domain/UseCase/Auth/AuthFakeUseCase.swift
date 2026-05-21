//
//  AuthFakeUseCase.swift
//  AppBase
//

import Combine
import Foundation

final class AuthFakeUseCase: AuthUseCaseProtocol {

    let isLoading = CurrentValueSubject<Bool, Never>(false)
    let didSucceed = PassthroughSubject<AuthResponse, Never>()
    let didFail = PassthroughSubject<TIOUserFacingError, Never>()

    private let requestDelay: TimeInterval = 1.0

    func login(email: String, password: String) {
        performAuth(email: email, password: password)
    }

    func register(email: String, password: String) {
        performAuth(email: email, password: password)
    }

    private func performAuth(email: String, password: String) {
        isLoading.send(true)
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + requestDelay) { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoading.send(false)
                guard !email.isEmpty, !password.isEmpty else {
                    self.didFail.send(.generic)
                    return
                }
                self.didSucceed.send(AuthResponse(token: "fake-token-\(UUID().uuidString)"))
            }
        }
    }
}
