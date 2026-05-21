//
//  LibraryFakeRepository.swift
//  AppBase
//

import Foundation

final class LibraryFakeRepository: LibraryRepositoryProtocol {

    private let delay: TimeInterval = 1.5

    func fetchPreview(completion: @escaping (LibraryContent) -> Void) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + delay) {
            let code = String(Int(Date().timeIntervalSince1970) % 10_000)
            completion(LibraryContent(
                title: L10n.Library.Loaded.title,
                subtitle: L10n.Library.Loaded.subtitle(code)
            ))
        }
    }
}
