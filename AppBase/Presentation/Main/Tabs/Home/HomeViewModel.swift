//
//  HomeViewModel.swift
//  AppBase
//
//  Created by Quang Anh Le on 11/5/26.
//

import BaseMVVM
import Combine
import Foundation
import UIKit
class HomeViewModel: TIOListViewModel {

    private let bankListUseCase: any GetBankListUseCaseProtocol

    private(set) var banks: [Bank] = []

    init(bankListUseCase: any GetBankListUseCaseProtocol) {
        self.bankListUseCase = bankListUseCase
        super.init()
    }

    override func numOfItemsInSection(_ section: Int) -> Int {
        banks.count
    }

    override func item(at indexPath: IndexPath) -> Any? {
        guard indexPath.row < banks.count else { return nil }
        return banks[indexPath.row]
    }

    override func viewModelDidReady() {
        super.viewModelDidReady()
        bindBankListUseCase()
        loadBanks()
    }

    override func refreshAndGetListData() {
        loadBanks()
    }

    override func loadMoreData() {
        // VietQR trả full list một lần — không phân trang.
    }

    override func hasReachedEnd() -> Bool {
        switch listDisplayState {
        case .content:
            return !banks.isEmpty
        case .empty, .error:
            return true
        }
    }

    // MARK: - Demo empty / error (nav bar test buttons)

    func showTestEmptyState() {
        stopLoading()
        banks = []
        setListContentState(.empty)
        dataDidChange.send()
    }

    func showTestErrorState() {
        stopLoading()
        banks = []
        setListContentState(.error(message: L10n.List.Error.message))
        dataDidChange.send()
    }

    /// SwiftEntryKit — toast lỗi (không đổi list state).
    func showTestToastError() {
        presentError(message: L10n.Home.Toast.testError)
    }

    /// SwiftEntryKit — toast thành công.
    func showTestToastSuccess() {
        presentSuccess(L10n.Home.Toast.testSuccess)
    }

    // MARK: - Fetch

    private func loadBanks() {
        clearListError()
        bankListUseCase.run(showsLoading: true)
    }

    // MARK: - UseCase binding

    private func bindBankListUseCase() {
        bindUseCase(
            useCase: bankListUseCase,
            storeIn: &cancellables,
            showsErrorToast: false,
            onSuccess: { [weak self] banks in
                self?.showBanks(banks)
            },
            onFailure: { [weak self] error in
                self?.showLoadError(message: error.message)
            }
        )
    }

    private func showBanks(_ banks: [Bank]) {
        self.banks = banks
        setListContentState(banks.isEmpty ? .empty : .content)
        dataDidChange.send()
    }

    private func showLoadError(message: String?) {
        banks = []
        setListContentState(.error(message: message))
        dataDidChange.send()
    }
}
