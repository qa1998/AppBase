//
//  DataStore.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//
import Foundation

final class DataStore: DataStoreProtocol {
    
    static let shared = DataStore()
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
}

// MARK: - Save

extension DataStore {
    
    func set<T: Encodable>( _ value: T,forKey key: StorageKey) {
        do {
            let data = try JSONEncoder().encode(value)
            userDefaults.set(data, forKey: key.rawValue)
        } catch {
            print("❌ DataStore Encode Error:", error)
        }
    }
}

// MARK: - Get

extension DataStore {
    
    func value<T: Decodable>(forKey key: StorageKey, type: T.Type) -> T? {
        guard let data = userDefaults.data(forKey: key.rawValue) else { return nil }
        
        do {
            return try JSONDecoder().decode(
                type,
                from: data
            )
        } catch {
            print("❌ DataStore Decode Error:", error)
            return nil
        }
    }
}

// MARK: - Remove

extension DataStore {
    
    func remove(forKey key: String ) {
        userDefaults.removeObject(forKey: key)
    }
    
    func clear() {
        userDefaults.dictionaryRepresentation().keys.forEach {userDefaults.removeObject(forKey: $0)}
    }
}

