//
//  UseCaseBinding.swift
//  AppBase
//

import Combine
import Foundation

/// Gắn publisher UseCase → `TIOViewModel` (loading, `trackError`, `trackSuccess`).
/// Store: `&cancellables` trên `TIOViewModel` — subclass không tạo Set riêng.
extension TIOViewModel where Event == TIOLoadingTarget {

    func bindUseCase<UC: TrackableUseCaseBindable, Success>(
        useCase: UC,
        storeIn cancellables: inout Set<AnyCancellable>,
        showsErrorToast: Bool = true,
        onSuccess: @escaping (Success) -> Void,
        onFailure: ((TIOUserFacingError) -> Void)? = nil
    ) where UC.Output == Success {
        useCase.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                if loading {
                    self?.startLoading()
                } else {
                    self?.stopLoading()
                }
            }
            .store(in: &cancellables)

        useCase.didSucceed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                onSuccess(value)
                if let message = useCase.pendingSuccessToastMessage {
                    self?.presentSuccess(message)
                    useCase.clearPendingSuccessToast()
                }
            }
            .store(in: &cancellables)

        useCase.didFail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let onFailure {
                    onFailure(error)
                } else if showsErrorToast, useCase.pendingShowsErrorToast {
                    self?.presentError(error)
                }
            }
            .store(in: &cancellables)
    }
}
