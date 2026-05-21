//
//  FootballPlayerStoreModels.swift
//  AppBase
//

import Foundation

struct FootballPlayersSnapshot: Codable, Equatable {
    var players: [FootballPlayer]
    var currentPlayerId: String?
}
