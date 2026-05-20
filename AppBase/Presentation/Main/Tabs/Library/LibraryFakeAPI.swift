//
//  LibraryFakeAPI.swift
//  AppBase
//

import Foundation

struct LibraryData {
    let title: String
    let subtitle: String
}

final class LibraryFakeAPI {

    static let shared = LibraryFakeAPI()

    private let delay: TimeInterval = 1.5

    private init() {}

    func fetch(completion: @escaping (LibraryData) -> Void) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + delay) {
            completion(LibraryData(
                title: "Library loaded",
                subtitle: "Fake API · \(Int(Date().timeIntervalSince1970) % 10_000)"
            ))
        }
    }
}
