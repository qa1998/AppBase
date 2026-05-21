//
//  PlayerEditorViewModel.swift
//  AppBase
//

import Combine
import Foundation
import UIKit

final class PlayerEditorViewModel: TIOViewModel<TIOLoadingTarget> {

    @Published private(set) var player: FootballPlayer

    private var storeCancel: AnyCancellable?

    override init() {
        player = PlayerStore.shared.currentPlayer
        super.init()
        storeCancel = PlayerStore.shared.currentPlayerDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updated in
                self?.player = updated
            }
    }

    func updateName(_ name: String) {
        apply { $0.updating(name: name, initials: FootballPlayer.makeInitials(from: name)) }
    }

    func setJerseyNumber(_ number: Int?) {
        apply { player in
            FootballPlayer(
                id: player.id,
                name: player.name,
                club: player.club,
                nation: player.nation,
                position: player.position,
                rating: player.rating,
                initials: player.initials,
                avatarFileName: player.avatarFileName,
                jerseyNumber: number
            )
        }
    }

    func setPosition(_ position: FootballPosition) {
        apply { $0.updating(position: position) }
    }

    func setAvatar(_ image: UIImage) {
        PlayerStore.shared.setAvatar(image)
    }

    func save() -> Bool {
        let name = player.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            presentError(message: L10n.Football.Players.validationName)
            return false
        }
        if let jersey = player.jerseyNumber, !(1...99).contains(jersey) {
            presentError(message: L10n.Football.Players.validationJersey)
            return false
        }
        PlayerStore.shared.saveCurrentPlayer()
        presentSuccess(L10n.Football.Players.saved)
        return true
    }

    private func apply(_ transform: (FootballPlayer) -> FootballPlayer) {
        PlayerStore.shared.updateCurrent(transform(player))
    }
}
