//
//  FormationContextMenu.swift
//  AppBase
//

import UIKit

enum FormationContextMenu {

    static func menu(
        playerCount: Int,
        selectedFormationId: String,
        onSelect: @escaping (FootballFormation) -> Void
    ) -> UIMenu {
        let formations = FootballFormation.formations(playerCount: playerCount)
        let actions = formations.map { formation in
            UIAction(
                title: formation.name,
                state: formation.id == selectedFormationId ? .on : .off
            ) { _ in
                onSelect(formation)
            }
        }
        return UIMenu(children: actions)
    }

    static func attach(
        to button: UIButton,
        playerCount: Int,
        selectedFormationId: String,
        onSelect: @escaping (FootballFormation) -> Void
    ) {
        button.showsMenuAsPrimaryAction = true
        button.menu = menu(
            playerCount: playerCount,
            selectedFormationId: selectedFormationId,
            onSelect: onSelect
        )
    }
}
