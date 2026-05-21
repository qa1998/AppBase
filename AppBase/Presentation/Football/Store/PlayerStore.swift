//
//  PlayerStore.swift
//  AppBase
//

import Combine
import Foundation
import UIKit

final class PlayerStore {

    static let shared = PlayerStore()

    let playersDidChange = PassthroughSubject<Void, Never>()
    let currentPlayerDidChange = PassthroughSubject<FootballPlayer, Never>()

    private(set) var players: [FootballPlayer] = []
    private(set) var currentPlayer: FootballPlayer

    private init() {
        if let snapshot = DataStore.shared.value(
            forKey: .footballPlayers,
            type: FootballPlayersSnapshot.self
        ) {
            players = snapshot.players
            if let id = snapshot.currentPlayerId,
               let player = players.first(where: { $0.id == id }) {
                currentPlayer = player
            } else {
                currentPlayer = FootballPlayer.custom(name: "", position: .mid)
            }
        } else {
            currentPlayer = FootballPlayer.custom(name: "", position: .mid)
            persist()
        }
    }

    /// Saved custom players + built-in catalog (deduped by id).
    var allPlayers: [FootballPlayer] {
        let savedIds = Set(players.map(\.id))
        let extras = FootballPlayer.catalog.filter { !savedIds.contains($0.id) }
        return players + extras
    }

    func player(id: String) -> FootballPlayer? {
        players.first { $0.id == id } ?? FootballPlayer.catalog.first { $0.id == id }
    }

    func createNewPlayer() {
        currentPlayer = FootballPlayer.custom(name: "", position: .mid)
        notifyCurrent()
    }

    func loadPlayer(_ player: FootballPlayer) {
        currentPlayer = player
        currentPlayerDidChange.send(player)
    }

    func updateCurrent(_ player: FootballPlayer) {
        currentPlayer = player
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index] = player
            persist()
            playersDidChange.send()
        }
        currentPlayerDidChange.send(player)
    }

    func saveCurrentPlayer() {
        var copy = currentPlayer
        if let index = players.firstIndex(where: { $0.id == copy.id }) {
            players[index] = copy
        } else {
            players.insert(copy, at: 0)
        }
        persist()
        notifyAll()
    }

    func deletePlayer(id: String) {
        if let player = players.first(where: { $0.id == id }) {
            FootballPlayerAvatarStorage.delete(fileName: player.avatarFileName)
        }
        players.removeAll { $0.id == id }
        if currentPlayer.id == id {
            currentPlayer = FootballPlayer.custom(name: "", position: .mid)
        }
        persist()
        playersDidChange.send()
        notifyCurrent()
    }

    func setAvatar(_ image: UIImage) {
        if let old = currentPlayer.avatarFileName {
            FootballPlayerAvatarStorage.delete(fileName: old)
        }
        let fileName = FootballPlayerAvatarStorage.save(image, playerId: currentPlayer.id)
        var copy = currentPlayer
        copy = FootballPlayer(
            id: copy.id,
            name: copy.name,
            club: copy.club,
            nation: copy.nation,
            position: copy.position,
            rating: copy.rating,
            initials: copy.initials,
            avatarFileName: fileName
        )
        currentPlayer = copy
        notifyCurrent()
    }

    private func persist() {
        let snapshot = FootballPlayersSnapshot(
            players: players,
            currentPlayerId: currentPlayer.id
        )
        DataStore.shared.set(snapshot, forKey: .footballPlayers)
    }

    private func notifyCurrent() {
        currentPlayerDidChange.send(currentPlayer)
    }

    private func notifyAll() {
        currentPlayerDidChange.send(currentPlayer)
        playersDidChange.send()
    }
}
