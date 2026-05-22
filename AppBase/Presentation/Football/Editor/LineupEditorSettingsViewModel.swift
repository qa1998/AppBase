//
//  LineupEditorSettingsViewModel.swift
//  AppBase
//

import Foundation

final class LineupEditorSettingsViewModel: TIOViewModel<TIOLoadingTarget> {

    let initialTitle: String

    init(title: String) {
        initialTitle = title
        super.init()
    }

    func saveTitle(_ title: String) {
        LineupStore.shared.updateCurrentLineupTitle(title)
        presentSuccess(L10n.Football.Editor.Settings.nameSaved)
    }
}
