//
//  ScriptDetailViewModel.swift
//  AppBase
//

import BaseMVVM
import Foundation

final class ScriptDetailViewModel: TIOViewModel {

    private let repository: ScriptRepository
    private(set) var script: TeleprompterScript

    init(repository: ScriptRepository, script: TeleprompterScript) {
        self.repository = repository
        self.script = script
        super.init()
    }

    func refreshFromStore() {
        if let latest = repository.script(id: script.id) {
            script = latest
        }
    }

    func deleteScript() {
        repository.delete(id: script.id)
    }
}
