//
//  ScriptRecording.swift
//  AppBase
//

import Foundation

struct ScriptRecording: Codable, Equatable, Identifiable {
    let id: UUID
    let scriptId: UUID
    let fileName: String
    let scriptAudioFileName: String?
    let createdAt: Date
    let duration: TimeInterval
    let audioMode: String?
    let originalVolume: Float?
    let scriptVolume: Float?

    init(
        id: UUID = UUID(),
        scriptId: UUID,
        fileName: String,
        scriptAudioFileName: String? = nil,
        createdAt: Date = Date(),
        duration: TimeInterval,
        audioMode: String? = nil,
        originalVolume: Float? = nil,
        scriptVolume: Float? = nil
    ) {
        self.id = id
        self.scriptId = scriptId
        self.fileName = fileName
        self.scriptAudioFileName = scriptAudioFileName
        self.createdAt = createdAt
        self.duration = duration
        self.audioMode = audioMode
        self.originalVolume = originalVolume
        self.scriptVolume = scriptVolume
    }
}
