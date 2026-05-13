//
//  RecordViewModel.swift
//  AppBase
//

import BaseMVVM
import Foundation
import Combine
final class RecordViewModel: TIOListViewModel {

    private let scriptRepository: ScriptRepository
    private let recordingRepository: ScriptRecordingRepository
    private(set) var scripts: [TeleprompterScript] = []

    init(
        scriptRepository: ScriptRepository = .shared,
        recordingRepository: ScriptRecordingRepository = .shared
    ) {

        self.scriptRepository = scriptRepository
        self.recordingRepository = recordingRepository

        super.init()
    }

    override func viewModelDidReady() {
        super.viewModelDidReady()
        reload()
    }

    override func numOfItemsInSection(
        _ section: Int
    ) -> Int {

        scripts.count
    }

    func reload() {

        scripts =
            scriptRepository.fetchSortedByDate()

        dataDidChange.send()
    }

    func script(
        at index: Int
    ) -> TeleprompterScript? {

        scripts.indices.contains(index)
        ? scripts[index]
        : nil
    }

    func recordingCount(
        scriptId: UUID
    ) -> Int {

        recordingRepository.recordingCount(
            scriptId: scriptId
        )
    }
}
