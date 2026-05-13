//
//  ScriptRecordingRepository.swift
//  AppBase
//

import Foundation

final class ScriptRecordingRepository {

    static let shared =
        ScriptRecordingRepository(
            store: DataStore.shared
        )

    private let store: DataStoreProtocol

    init(store: DataStoreProtocol) {
        self.store = store
    }

    func recordings(
        scriptId: UUID
    ) -> [ScriptRecording] {

        fetchAll()
            .filter {
                $0.scriptId == scriptId
            }
            .sorted {
                $0.createdAt > $1.createdAt
            }
    }

    func recordingCount(
        scriptId: UUID
    ) -> Int {

        recordings(
            scriptId: scriptId
        ).count
    }

    func save(
        _ recording: ScriptRecording
    ) {

        var all =
            fetchAll()

        if let index =
            all.firstIndex(
                where: {
                    $0.id == recording.id
                }
            ) {

            all[index] = recording

        } else {

            all.insert(
                recording,
                at: 0
            )
        }

        store.set(
            all,
            forKey: .scriptRecordings
        )
    }

    func delete(
        _ recording: ScriptRecording
    ) {

        var all =
            fetchAll()

        all.removeAll {
            $0.id == recording.id
        }

        store.set(
            all,
            forKey: .scriptRecordings
        )

        try? FileManager.default.removeItem(
            at: fileURL(
                for: recording
            )
        )

        if let scriptAudioURL =
            scriptAudioURL(
                for: recording
            ) {

            try? FileManager.default.removeItem(
                at: scriptAudioURL
            )
        }
    }

    func createFileURL(
        scriptId: UUID,
        fileExtension: String = "mov"
    ) throws -> URL {

        let directory =
            try directoryURL(
                scriptId: scriptId
            )

        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        let normalizedExtension =
            fileExtension.isEmpty
            ? "mov"
            : fileExtension

        return directory.appendingPathComponent(
            "\(UUID().uuidString).\(normalizedExtension)"
        )
    }

    func fileURL(
        for recording: ScriptRecording
    ) -> URL {

        recordingsRootURL()
            .appendingPathComponent(
                recording.scriptId.uuidString,
                isDirectory: true
            )
            .appendingPathComponent(
                recording.fileName
            )
    }

    func scriptAudioURL(
        for recording: ScriptRecording
    ) -> URL? {

        guard let scriptAudioFileName =
                recording.scriptAudioFileName
        else {
            return nil
        }

        return recordingsRootURL()
            .appendingPathComponent(
                recording.scriptId.uuidString,
                isDirectory: true
            )
            .appendingPathComponent(
                scriptAudioFileName
            )
    }

    private func fetchAll() -> [ScriptRecording] {

        store.value(
            forKey: .scriptRecordings,
            type: [ScriptRecording].self
        ) ?? []
    }

    private func directoryURL(
        scriptId: UUID
    ) throws -> URL {

        recordingsRootURL()
            .appendingPathComponent(
                scriptId.uuidString,
                isDirectory: true
            )
    }

    private func recordingsRootURL() -> URL {

        let documents =
            FileManager
                .default
                .urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                )[0]

        return documents.appendingPathComponent(
            "Script Video Recordings",
            isDirectory: true
        )
    }
}
