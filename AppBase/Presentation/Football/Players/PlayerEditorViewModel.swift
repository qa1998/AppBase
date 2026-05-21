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
        apply {
            FootballPlayer(
                id: $0.id,
                name: name,
                club: $0.club,
                nation: $0.nation,
                position: $0.position,
                rating: $0.rating,
                initials: FootballPlayer.makeInitials(from: name),
                avatarFileName: $0.avatarFileName
            )
        }
    }

    func setPosition(_ position: FootballPosition) {
        apply { copy in
            FootballPlayer(
                id: copy.id,
                name: copy.name,
                club: copy.club,
                nation: copy.nation,
                position: position,
                rating: copy.rating,
                initials: copy.initials,
                avatarFileName: copy.avatarFileName
            )
        }
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
        PlayerStore.shared.saveCurrentPlayer()
        presentSuccess(L10n.Football.Players.saved)
        return true
    }

    private func apply(_ transform: (FootballPlayer) -> FootballPlayer) {
        var copy = transform(player)
        PlayerStore.shared.updateCurrent(copy)
    }
}
