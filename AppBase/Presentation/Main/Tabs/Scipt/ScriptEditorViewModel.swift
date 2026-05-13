//
//  ScriptEditorViewModel.swift
//  AppBase
//

import BaseMVVM
import Foundation

final class ScriptEditorViewModel: TIOViewModel {

    private let repository: ScriptRepository
    private(set) var editingScript: TeleprompterScript?

    var isEditing: Bool { editingScript != nil }

    init(repository: ScriptRepository, script: TeleprompterScript?) {
        self.repository = repository
        self.editingScript = script
        super.init()
    }

    func save(title: String, content: String) -> TeleprompterScript {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTitle = trimmedTitle.isEmpty ? "Script mới" : trimmedTitle
        var script = editingScript ?? TeleprompterScript(title: finalTitle, content: content)
        script.title = finalTitle
        script.content = content
        script.updatedAt = Date()
        repository.save(script)
        editingScript = script
        return script
    }
}
