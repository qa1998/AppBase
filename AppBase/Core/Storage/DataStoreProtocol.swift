//
//  DataStoreProtocol.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//


protocol DataStoreProtocol {
    
    // MARK: - Save
    func set<T: Encodable>(_ value: T,forKey key: StorageKey)
    
    // MARK: - Get
    func value<T: Decodable>(forKey key: StorageKey,type: T.Type) -> T?

    // MARK: - Remove
    func remove(forKey key: String)
    
    // MARK: - Clear
    func clear()
}
