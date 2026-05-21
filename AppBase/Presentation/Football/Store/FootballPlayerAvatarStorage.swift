//
//  FootballPlayerAvatarStorage.swift
//  AppBase
//

import UIKit

enum FootballPlayerAvatarStorage {

    private static var directory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("FootballPlayerAvatars", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func save(_ image: UIImage, playerId: String) -> String? {
        let fileName = "\(playerId).jpg"
        let url = directory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        do {
            try data.write(to: url, options: .atomic)
            return fileName
        } catch {
            return nil
        }
    }

    static func load(fileName: String) -> UIImage? {
        let url = directory.appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func delete(fileName: String?) {
        guard let fileName else { return }
        let url = directory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
    }
}
