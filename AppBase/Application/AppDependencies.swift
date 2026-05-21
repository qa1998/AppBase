//
//  AppDependencies.swift
//  AppBase
//

import Foundation

/// DI container — RepoFactory → ServiceFactory → UseCase.
///
/// - `bankList`: Home (VietQR API thật hoặc fake).
/// - `libraryRepository`: tab Library — demo shimmer, fake repo.
/// - Login/Auth: UI demo only — chưa inject (xem `Presentation/Login/`).
struct AppDependencies {

    let bankList: any GetBankListUseCaseProtocol
    let libraryRepository: LibraryRepositoryProtocol

    init(
        bankList: any GetBankListUseCaseProtocol,
        libraryRepository: LibraryRepositoryProtocol
    ) {
        self.bankList = bankList
        self.libraryRepository = libraryRepository
    }

    static let live = AppDependencies(useFakeData: false)
    static let fake = AppDependencies(useFakeData: true)

    init(useFakeData: Bool) {
        let bankRepo = RepoFactory.makeBankRepository(useFake: useFakeData)
        let bankService = ServiceFactory.makeBankService(repository: bankRepo)
        self.bankList = GetBankListUseCase(service: bankService)
        self.libraryRepository = LibraryFakeRepository()
    }

    static func make(useFakeData: Bool? = nil) -> AppDependencies {
        #if DEBUG
        let useFake = useFakeData ?? false
        return AppDependencies(useFakeData: useFake)
        #else
        return .live
        #endif
    }
}
