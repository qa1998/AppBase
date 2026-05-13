//
//  ElevenLabsSpeechProvider.swift
//  AppBase
//

import Foundation

final class ElevenLabsSpeechProvider: RemoteSpeechProvider {

    struct VoiceSettings: Encodable, Equatable {
        var stability: Double = 0.5
        var similarityBoost: Double = 0.75
        var style: Double = 0.0
        var useSpeakerBoost: Bool = true

        enum CodingKeys: String, CodingKey {
            case stability
            case similarityBoost = "similarity_boost"
            case style
            case useSpeakerBoost = "use_speaker_boost"
        }
    }

    enum ProviderError: LocalizedError {
        case missingAPIKey
        case invalidURL
        case emptyText
        case emptyAudioData
        case httpStatus(Int, String?)

        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return L10n.elevenlabsErrorMissingAPIKey
            case .invalidURL:
                return L10n.elevenlabsErrorInvalidURL
            case .emptyText:
                return L10n.elevenlabsErrorEmptyText
            case .emptyAudioData:
                return L10n.elevenlabsErrorEmptyAudioData
            case let .httpStatus(statusCode, message):
                if let message,
                   !message.isEmpty {

                    return L10n.elevenlabsErrorStatusMessage(
                        statusCode,
                        message
                    )
                }

                return L10n.elevenlabsErrorStatus(
                    statusCode
                )
            }
        }
    }

    private struct VoicesResponse: Decodable {
        let voices: [Voice]
    }

    private struct Voice: Decodable {
        let voiceId: String
        let name: String
        let category: String?
        let previewUrl: String?

        enum CodingKeys: String, CodingKey {
            case voiceId = "voice_id"
            case name
            case category
            case previewUrl = "preview_url"
        }
    }

    private struct SynthesisBody: Encodable {
        let text: String
        let modelId: String
        let voiceSettings: VoiceSettings

        enum CodingKeys: String, CodingKey {
            case text
            case modelId = "model_id"
            case voiceSettings = "voice_settings"
        }
    }

    private let apiKeyProvider: () -> String?
    private let session: URLSession
    private let baseURL: URL

    var modelId: String
    var outputFormat: String
    var voiceSettings: VoiceSettings

    init(
        apiKeyProvider: @escaping () -> String?,
        session: URLSession = .shared,
        baseURL: URL = URL(string: "https://api.elevenlabs.io/v1")!,
        modelId: String = "eleven_multilingual_v2",
        outputFormat: String = "mp3_44100_128",
        voiceSettings: VoiceSettings = VoiceSettings()
    ) {

        self.apiKeyProvider = apiKeyProvider
        self.session = session
        self.baseURL = baseURL
        self.modelId = modelId
        self.outputFormat = outputFormat
        self.voiceSettings = voiceSettings
    }

    func fetchVoices(
        completion: @escaping (Result<[RemoteSpeechVoice], Error>) -> Void
    ) {

        guard let request =
                makeRequest(
                    path: "voices",
                    method: "GET",
                    accept: "application/json"
                )
        else {
            completion(
                .failure(
                    ProviderError.missingAPIKey
                )
            )
            return
        }

        session.dataTask(
            with: request
        ) {
            data,
            response,
            error in

            if let error {
                completion(
                    .failure(error)
                )
                return
            }

            if let error =
                self.validateHTTPResponse(
                    response,
                    data: data
                ) {

                completion(
                    .failure(error)
                )
                return
            }

            do {

                let response =
                    try JSONDecoder().decode(
                        VoicesResponse.self,
                        from: data ?? Data()
                    )

                completion(
                    .success(
                        response.voices.map {
                            RemoteSpeechVoice(
                                id: $0.voiceId,
                                name: $0.name,
                                category: $0.category,
                                previewURL: $0.previewUrl.flatMap(URL.init(string:))
                            )
                        }
                    )
                )

            } catch {

                completion(
                    .failure(error)
                )
            }
        }.resume()
    }

    func synthesizeSpeech(
        request: RemoteSpeechRequest,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {

        let text =
            request.text.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !text.isEmpty else {
            completion(
                .failure(
                    ProviderError.emptyText
                )
            )
            return
        }

        guard var urlRequest =
                makeRequest(
                    path: "text-to-speech/\(request.voiceId)",
                    method: "POST",
                    accept: "audio/mpeg",
                    queryItems: [
                        URLQueryItem(
                            name: "output_format",
                            value: outputFormat
                        )
                    ]
                )
        else {
            completion(
                .failure(
                    ProviderError.missingAPIKey
                )
            )
            return
        }

        do {

            urlRequest.httpBody =
                try JSONEncoder().encode(
                    SynthesisBody(
                        text: text,
                        modelId: modelId,
                        voiceSettings: voiceSettings
                    )
                )

        } catch {

            completion(
                .failure(error)
            )
            return
        }

        session.dataTask(
            with: urlRequest
        ) {
            data,
            response,
            error in

            if let error {
                completion(
                    .failure(error)
                )
                return
            }

            if let error =
                self.validateHTTPResponse(
                    response,
                    data: data
                ) {

                completion(
                    .failure(error)
                )
                return
            }

            guard let data,
                  !data.isEmpty
            else {
                completion(
                    .failure(
                        ProviderError.emptyAudioData
                    )
                )
                return
            }

            do {

                let directoryURL =
                    request.outputURL
                        .deletingLastPathComponent()

                try FileManager.default.createDirectory(
                    at: directoryURL,
                    withIntermediateDirectories: true
                )

                if FileManager.default.fileExists(
                    atPath: request.outputURL.path
                ) {

                    try FileManager.default.removeItem(
                        at: request.outputURL
                    )
                }

                try data.write(
                    to: request.outputURL,
                    options: .atomic
                )

                completion(
                    .success(
                        request.outputURL
                    )
                )

            } catch {

                completion(
                    .failure(error)
                )
            }
        }.resume()
    }

    private func makeRequest(
        path: String,
        method: String,
        accept: String,
        queryItems: [URLQueryItem] = []
    ) -> URLRequest? {

        guard let apiKey =
                apiKeyProvider()?.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
              !apiKey.isEmpty
        else {
            return nil
        }

        let endpointURL =
            baseURL.appendingPathComponent(
                path
            )

        guard var components =
                URLComponents(
                    url: endpointURL,
                    resolvingAgainstBaseURL: false
                )
        else {
            return nil
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url =
                components.url
        else {
            return nil
        }

        var request =
            URLRequest(
                url: url
            )

        request.httpMethod = method

        request.setValue(
            apiKey,
            forHTTPHeaderField: "xi-api-key"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            accept,
            forHTTPHeaderField: "Accept"
        )

        return request
    }

    private func validateHTTPResponse(
        _ response: URLResponse?,
        data: Data?
    ) -> Error? {

        guard let response =
                response as? HTTPURLResponse
        else {
            return nil
        }

        guard !(200...299).contains(
            response.statusCode
        )
        else {
            return nil
        }

        let message =
            data.flatMap {
                String(
                    data: $0,
                    encoding: .utf8
                )
            }

        return ProviderError.httpStatus(
            response.statusCode,
            message
        )
    }
}
