//
//  TeleprompterPlaybackStore.swift
//  AppBase
//

import Foundation

/// Lưu vị trí đọc cuối (UTF-16 offset) theo `scriptId`.
enum TeleprompterPlaybackStore {

    private static let prefix = "teleprompter.lastReadUTF16."

    static func lastReadOffset(scriptId: UUID) -> Int {
        UserDefaults.standard.integer(forKey: prefix + scriptId.uuidString)
    }

    static func saveLastReadOffset(_ offset: Int, scriptId: UUID) {
        UserDefaults.standard.set(offset, forKey: prefix + scriptId.uuidString)
    }

    static func clear(scriptId: UUID) {
        UserDefaults.standard.removeObject(forKey: prefix + scriptId.uuidString)
    }
}
