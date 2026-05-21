//
//  GetBankListUseCase.swift
//  AppBase
//

import Combine
import Foundation

protocol GetBankListUseCaseProtocol: TrackableUseCaseBindable where Output == [Bank] {

    func run(
        showsLoading: Bool,
        showsSuccessToast: Bool,
        successToastMessage: String?
    )
}

extension GetBankListUseCaseProtocol {

    func run(showsLoading: Bool = true) {
        run(showsLoading: showsLoading, showsSuccessToast: false, successToastMessage: nil)
    }
}

final class GetBankListUseCase: TrackableUseCase<GetBankListUseCase.Input, [Bank]>,
                                  GetBankListUseCaseProtocol {

    private let service: BankServiceProtocol

    init(service: BankServiceProtocol) {
        self.service = service
        super.init()
    }

    func run(
        showsLoading: Bool = true,
        showsSuccessToast: Bool = false,
        successToastMessage: String? = nil
    ) {
        run(Input(
            showsLoading: showsLoading,
            showsSuccessToast: showsSuccessToast,
            successToastMessage: successToastMessage
        ))
    }

    override func execute(_ input: Input) -> AnyPublisher<[Bank], APIError> {
        service.getBanks()
    }

    struct Input: TrackableUseCaseInput {
        var showsLoading: Bool = true
        var showsSuccessToast: Bool = false
        var showsErrorToast: Bool = true
        var successToastMessage: String? = nil
    }
}
