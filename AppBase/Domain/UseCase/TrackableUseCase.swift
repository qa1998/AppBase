//
//  TrackableUseCase.swift
//  AppBase
//
//  UseCase + track loading / success / error cho ViewModel (Combine).
//

import Combine
import Foundation

/// Base có `execute` + `run` phát subject (bind `TIOViewModel`).
class TrackableUseCase<Input: TrackableUseCaseInput, Output>: UseCase<Input, Output> {

    let isLoading = CurrentValueSubject<Bool, Never>(false)
    let didSucceed = PassthroughSubject<Output, Never>()
    let didFail = PassthroughSubject<TIOUserFacingError, Never>()

    private(set) var pendingSuccessToastMessage: String?
    private(set) var pendingShowsErrorToast = true

    private var cancellables = Set<AnyCancellable>()

    /// Gọi `execute`, cập nhật loading / success / error.
    func run(_ input: Input) {
        pendingShowsErrorToast = input.showsErrorToast
        pendingSuccessToastMessage = input.showsSuccessToast ? input.successToastMessage : nil

        let showsLoading = shouldShowLoading(for: input)
        if showsLoading {
            isLoading.send(true)
        }

        execute(input)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    if showsLoading {
                        self.isLoading.send(false)
                    }
                    if case .failure(let error) = completion {
                        self.didFail.send(error.userFacing)
                    }
                },
                receiveValue: { [weak self] output in
                    self?.didSucceed.send(output)
                }
            )
            .store(in: &cancellables)
    }

    func clearPendingSuccessToast() {
        pendingSuccessToastMessage = nil
    }

    /// Override nếu `Input` có flag `showsLoading`.
    open func shouldShowLoading(for input: Input) -> Bool {
        input.showsLoading
    }
}

extension TrackableUseCase: TrackableUseCaseBindable {}
