//
//  AuthUseCaseProtocol.swift
//  AppBase
//

import Combine
import Foundation

protocol AuthUseCaseProtocol: AnyObject {

    var isLoading: CurrentValueSubject<Bool, Never> { get }
    var didSucceed: PassthroughSubject<AuthResponse, Never> { get }
    var didFail: PassthroughSubject<TIOUserFacingError, Never> { get }

    func login(email: String, password: String)
    func register(email: String, password: String)
}
