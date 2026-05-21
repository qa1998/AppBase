//
//  UseCasePublisher.swift
//  AppBase
//

import Combine
import Foundation

enum UseCasePublisher {

    /// Bridge callback API → `AnyPublisher` (giống `Single` trong RxSwift).
    static func make<T>(
        _ work: @escaping (@escaping (Result<T, APIError>) -> Void) -> Void
    ) -> AnyPublisher<T, APIError> {
        Deferred {
            Future { promise in
                work { promise($0) }
            }
        }
        .eraseToAnyPublisher()
    }
}
