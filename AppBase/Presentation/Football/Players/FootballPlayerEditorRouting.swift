//
//  FootballPlayerEditorRouting.swift
//  AppBase
//

import UIKit
import BaseMVVM

enum FootballPlayerEditorRouting {

    static func pushNewPlayer(
        from picker: PlayerPickerViewController,
        navigationController: UINavigationController
    ) {
        PlayerStore.shared.createNewPlayer()
        let editor = PlayerEditorViewController()
        editor.hidesBottomBarWhenPushed = true
        editor.invoke(viewModel: PlayerEditorViewModel())
        editor.onSaved = { [weak picker] in
            guard let picker else { return }
            let player = PlayerStore.shared.currentPlayer
            navigationController.popViewController(animated: true) {
                picker.finishWithCreatedPlayer(player)
            }
        }
        navigationController.pushViewController(editor, animated: true)
    }
}
