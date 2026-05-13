//
//  ScriptViewModel.swift
//  AppBase
//

import BaseMVVM
import Foundation
import Combine
final class ScriptViewModel: TIOListViewModel {

    private let repository: ScriptRepository
    private var allScripts: [TeleprompterScript] = []
    private(set) var filteredScripts: [TeleprompterScript] = []
    private var searchText: String = ""

    init(repository: ScriptRepository = .shared) {
        self.repository = repository
        super.init()
    }

    override func viewModelDidReady() {
        super.viewModelDidReady()
        reload()
    }

    override func numOfItemsInSection(_ section: Int) -> Int {
        filteredScripts.count
    }

    func reload() {
        allScripts = repository.fetchSortedByDate()
        applyFilter()
        dataDidChange.send()
    }

    func setSearch(_ text: String) {
        searchText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        applyFilter()
        dataDidChange.send()
    }

    private func applyFilter() {
        if searchText.isEmpty {
            filteredScripts = allScripts
        } else {
            filteredScripts = allScripts.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
                    || $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    func script(at index: Int) -> TeleprompterScript? {
        filteredScripts.indices.contains(index) ? filteredScripts[index] : nil
    }

    var hasNoSavedScripts: Bool {
        allScripts.isEmpty
    }

    var isShowingEmptySearch: Bool {
        !allScripts.isEmpty && filteredScripts.isEmpty
    }
}
