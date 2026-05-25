//
//  FormationFavoritesStore.swift
//  AppBase
//

import Foundation

/// Favorite formation ids (persisted).
final class FormationFavoritesStore {

    static let shared = FormationFavoritesStore()

    private let key = "football.formation.favorites"
    private var ids: Set<String>

    private init() {
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? []
        ids = Set(saved)
    }

    func isFavorite(_ formationId: String) -> Bool {
        ids.contains(formationId)
    }

    func toggleFavorite(_ formationId: String) {
        if ids.contains(formationId) {
            ids.remove(formationId)
        } else {
            ids.insert(formationId)
        }
        UserDefaults.standard.set(Array(ids), forKey: key)
    }

    func resetAfterDataClear() {
        ids.removeAll()
        UserDefaults.standard.removeObject(forKey: key)
    }
}
