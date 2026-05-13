//
//  ScriptRepository.swift
//  AppBase
//

import Foundation

final class ScriptRepository {

    static let shared = ScriptRepository(store: DataStore.shared)

    private let store: DataStoreProtocol

    init(store: DataStoreProtocol) {
        self.store = store
    }

    func fetchAll() -> [TeleprompterScript] {
        store.value(forKey: .teleprompterScripts, type: [TeleprompterScript].self) ?? []
    }

    func fetchSortedByDate() -> [TeleprompterScript] {
        fetchAll().sorted { $0.updatedAt > $1.updatedAt }
    }

    func save(_ script: TeleprompterScript) {
        var all = fetchAll()
        if let index = all.firstIndex(where: { $0.id == script.id }) {
            all[index] = script
        } else {
            all.insert(script, at: 0)
        }
        store.set(all, forKey: .teleprompterScripts)
    }

    func delete(id: UUID) {
        var all = fetchAll()
        all.removeAll { $0.id == id }
        store.set(all, forKey: .teleprompterScripts)
    }

    func script(id: UUID) -> TeleprompterScript? {
        fetchAll().first { $0.id == id }
    }
}
