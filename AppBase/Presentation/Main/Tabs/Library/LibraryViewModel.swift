//
//  LibraryViewModel.swift
//  AppBase
//

import BaseMVVM
import Combine
import Foundation

class LibraryViewModel: TIOViewModel<LibraryLoadingEvent> {

    private let repository: LibraryRepositoryProtocol

    let titleText = CurrentValueSubject<String, Never>(L10n.Library.title)
    let subtitleText = CurrentValueSubject<String, Never>(L10n.Library.Subtitle.hint)

    init(repository: LibraryRepositoryProtocol) {
        self.repository = repository
        super.init()
    }

    func runFakeLoad(for target: LibraryLoadingEvent) {
        startLoading(target)
        repository.fetchPreview { [weak self] content in
            DispatchQueue.main.async {
                guard let self else { return }
                self.stopLoading(target)
                switch target {
                case .screen, .title:
                    self.titleText.send(content.title)
                case .subtitle:
                    break
                }
                switch target {
                case .screen, .subtitle:
                    self.subtitleText.send(content.subtitle)
                case .title:
                    break
                }
            }
        }
    }
}
