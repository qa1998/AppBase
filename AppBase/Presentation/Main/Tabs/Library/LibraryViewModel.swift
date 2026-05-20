//
//  LibraryViewModel.swift
//  AppBase
//

import BaseMVVM
import Combine
import Foundation

class LibraryViewModel: TIOViewModel<LibraryLoadingEvent> {

    private let fakeAPI = LibraryFakeAPI.shared

    let titleText = CurrentValueSubject<String, Never>(L10n.Library.title)
    let subtitleText = CurrentValueSubject<String, Never>(L10n.Library.Subtitle.hint)

    func runFakeLoad(for target: LibraryLoadingEvent) {
        startLoading(target)
        fakeAPI.fetch { [weak self] data in
            DispatchQueue.main.async {
                guard let self else { return }
                self.titleText.send(data.title)
                self.subtitleText.send(data.subtitle)
                self.stopLoading(target)
            }
        }
    }
}
