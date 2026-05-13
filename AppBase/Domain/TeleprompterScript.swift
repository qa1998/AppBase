//
//  TeleprompterScript.swift
//  AppBase
//

import Foundation

struct TeleprompterScript: Codable, Equatable, Identifiable {
    let id: UUID
    var title: String
    var content: String
    var updatedAt: Date

    init(id: UUID = UUID(), title: String, content: String, updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.updatedAt = updatedAt
    }

    /// Rough read time for subtitle (storyboard: "3 phút")
    var estimatedReadMinutes: Int {
        let words = content.split { $0.isWhitespace || $0.isNewline }.count
        return max(1, (words + 149) / 150)
    }
}
