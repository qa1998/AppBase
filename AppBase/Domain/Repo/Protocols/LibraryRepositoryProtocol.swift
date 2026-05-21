//
//  LibraryRepositoryProtocol.swift
//  AppBase
//

import Foundation

/// Demo shimmer tab — fake delay, không gọi API.
protocol LibraryRepositoryProtocol: AnyObject {

    func fetchPreview(completion: @escaping (LibraryContent) -> Void)
}
