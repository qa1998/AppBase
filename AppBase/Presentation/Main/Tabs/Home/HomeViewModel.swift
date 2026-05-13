//
//  HomeViewModel.swift
//  AppBase
//

import BaseMVVM
import Foundation
import Combine
final class HomeViewModel: TIOListViewModel {

    private let repository: ScriptRepository

    private(set) var recentScripts: [TeleprompterScript] = []

    init(repository: ScriptRepository = .shared) {
        self.repository = repository
        super.init()
    }

    override func viewModelDidReady() {
        super.viewModelDidReady()
        reload()
    }

    override func numOfItemsInSection(_ section: Int) -> Int {
        recentScripts.count
    }

    func reload() {
        recentScripts = Array(repository.fetchSortedByDate().prefix(10))
        dataDidChange.send()
    }

    func script(at index: Int) -> TeleprompterScript? {
        recentScripts.indices.contains(index) ? recentScripts[index] : nil
    }

    override func didSelectItem(at indexPath: IndexPath) {
        // HomeViewController overrides tableView didSelect; kept for consistency.
    }
}
