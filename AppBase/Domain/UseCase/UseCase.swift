//
//  UseCase.swift
//  AppBase
//
//  Pattern: UseCase<Input, Output> + execute(_:) — tương đương Rx Single, dùng Combine.
//

import Combine
import Foundation

// MARK: - Void input

struct VoidInput {}

// MARK: - Protocol

protocol IUseCase {

    associatedtype Input
    associatedtype Output

    func execute(_ input: Input) -> AnyPublisher<Output, APIError>
}

extension IUseCase where Input == VoidInput {

    func execute() -> AnyPublisher<Output, APIError> {
        execute(VoidInput())
    }
}

// MARK: - Base class

class UseCase<Input, Output>: IUseCase {

    func execute(_ input: Input) -> AnyPublisher<Output, APIError> {
        fatalError("\(Self.self) must override execute(_:)")
    }
}
