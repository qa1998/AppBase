//
//  MyPlayersViewModel.swift
//  AppBase
//

import Combine
import Foundation

final class MyPlayersViewModel: TIOViewModel<TIOLoadingTarget> {

    @Published private(set) var players: [FootballPlayer] = []

    private var storeCancel: AnyCancellable?

    override init() {
        super.init()
        reload()
        storeCancel = PlayerStore.shared.playersDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.reload()
            }
    }

    func reload() {
        players = PlayerStore.shared.players.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    func openPlayer(_ player: FootballPlayer) {
        PlayerStore.shared.loadPlayer(player)
    }

    func createPlayer() {
        PlayerStore.shared.createNewPlayer()
    }

    func deletePlayer(_ player: FootballPlayer) {
        PlayerStore.shared.deletePlayer(id: player.id)
        reload()
    }
}
