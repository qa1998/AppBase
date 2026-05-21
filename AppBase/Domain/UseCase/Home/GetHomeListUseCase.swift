//
//  GetHomeListUseCase.swift
//  AppBase
//
//  Ví dụ: UCGetListQuestionWrong — Input struct + execute + Service DI.
//

import Combine
import Foundation

// MARK: - Protocol (DI)

protocol GetHomeListUseCaseProtocol: AnyObject {

    var isLoading: CurrentValueSubject<Bool, Never> { get }
    var didSucceed: PassthroughSubject<HomeListPage, Never> { get }
    var didFail: PassthroughSubject<TIOUserFacingError, Never> { get }

    func run(_ input: GetHomeListUseCase.Input)
}

// MARK: - Use case

final class GetHomeListUseCase: TrackableUseCase<GetHomeListUseCase.Input, HomeListPage>,
                                  GetHomeListUseCaseProtocol {

    private let service: HomeServiceProtocol

    init(service: HomeServiceProtocol) {
        self.service = service
        super.init()
    }

    override func execute(_ input: Input) -> AnyPublisher<HomeListPage, APIError> {
        service.getHomeList(page: input.page)
    }

    override func shouldShowLoading(for input: Input) -> Bool {
        input.showsLoading
    }

    // MARK: - Input

    struct Input: TrackableUseCaseInput {
        var page: Int = 1
        var showsLoading: Bool = true
        var showsSuccessToast: Bool = false
        var showsErrorToast: Bool = true
        var successToastMessage: String? = nil
    }
}

/// Alias giữ tương thích code cũ.
typealias HomeListUseCaseProtocol = GetHomeListUseCaseProtocol
