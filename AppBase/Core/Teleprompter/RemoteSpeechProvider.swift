//
//  RemoteSpeechProvider.swift
//  AppBase
//

import Foundation

struct RemoteSpeechVoice: Equatable {
    let id: String
    let name: String
    let category: String?
    let previewURL: URL?

    var displayName: String {
        guard let category,
              !category.isEmpty
        else {
            return name
        }

        return L10n.teleprompterVoicePickerOptionFormat(
            name,
            category
        )
    }
}

struct RemoteSpeechRequest {
    let text: String
    let voiceId: String
    let outputURL: URL
}

protocol RemoteSpeechProvider {
    func fetchVoices(
        completion: @escaping (Result<[RemoteSpeechVoice], Error>) -> Void
    )

    func synthesizeSpeech(
        request: RemoteSpeechRequest,
        completion: @escaping (Result<URL, Error>) -> Void
    )
}
