//
//  CreateMatchViewModel.swift
//  AppBase
//

import Foundation

final class CreateMatchViewModel: TIOViewModel<TIOLoadingTarget> {

    var homeTeam = ""
    var awayTeam = ""
    var pitchSize: MatchPitchSize = .eleven
    var kickoffDate = Date()
    var firstHalfMinutes = FootballMatchSettings.defaultFirstHalf
    var secondHalfMinutes = FootballMatchSettings.defaultSecondHalf
    var hasExtraTime = false
    var hasPenaltyShootout = false

    private(set) var homeRoster: MatchTeamRoster
    private(set) var awayRoster: MatchTeamRoster
    private(set) var homeTeamTemplateId: String?
    private(set) var awayTeamTemplateId: String?

    override init() {
        homeRoster = MatchTeamRoster.empty(name: "", pitchSize: .eleven)
        awayRoster = MatchTeamRoster.empty(name: "", pitchSize: .eleven)
        super.init()
    }

    func setPitchSize(_ size: MatchPitchSize) {
        pitchSize = size
        homeTeamTemplateId = nil
        awayTeamTemplateId = nil
        refreshRostersForPitchSize()
    }

    func applySavedTeam(_ team: FootballTeam, side: MatchTeamSide) {
        pitchSize = team.pitchSize
        var roster = team.toMatchRoster()
        if side == .home {
            homeTeam = team.name
            homeRoster = roster
            homeTeamTemplateId = team.id
        } else {
            awayTeam = team.name
            awayRoster = roster
            awayTeamTemplateId = team.id
        }
    }

    var canSkipTeamSetup: Bool {
        homeRoster.isComplete && awayRoster.isComplete
    }

    func updateTeamNames() {
        homeRoster.name = homeTeam
        awayRoster.name = awayTeam
    }

    func roster(for side: MatchTeamSide) -> MatchTeamRoster {
        side == .home ? homeRoster : awayRoster
    }

    func updateRoster(_ roster: MatchTeamRoster, for side: MatchTeamSide) {
        if side == .home {
            homeRoster = roster
            homeTeam = roster.name
        } else {
            awayRoster = roster
            awayTeam = roster.name
        }
    }

    func assignPlayer(_ player: FootballPlayer, to slot: MatchRosterSlot, side: MatchTeamSide) {
        var roster = roster(for: side)
        switch slot {
        case .pitch(let index):
            guard roster.assignments.indices.contains(index) else { return }
            roster.assignments[index].player = player
        case .bench(let index):
            roster.setBenchPlayer(player, at: index)
        }
        updateRoster(roster, for: side)
    }

    func canContinueToTeamSetup() -> Bool {
        let home = homeTeam.trimmingCharacters(in: .whitespacesAndNewlines)
        let away = awayTeam.trimmingCharacters(in: .whitespacesAndNewlines)
        return !home.isEmpty && !away.isEmpty
    }

    func createMatch() -> FootballMatch? {
        updateTeamNames()
        guard canContinueToTeamSetup() else {
            presentError(message: L10n.Football.Match.Create.validationTeams)
            return nil
        }
        guard homeRoster.isComplete, awayRoster.isComplete else {
            presentError(message: L10n.Football.Match.Create.validationPlayers)
            return nil
        }
        let settings = FootballMatchSettings(
            homeTeam: homeTeam.trimmingCharacters(in: .whitespacesAndNewlines),
            awayTeam: awayTeam.trimmingCharacters(in: .whitespacesAndNewlines),
            pitchSize: pitchSize,
            kickoffDate: kickoffDate,
            firstHalfMinutes: firstHalfMinutes,
            secondHalfMinutes: secondHalfMinutes,
            extraTimeHalfMinutes: FootballMatchSettings.defaultExtraHalf,
            hasExtraTime: hasExtraTime,
            hasPenaltyShootout: hasPenaltyShootout,
            homeRoster: homeRoster,
            awayRoster: awayRoster
        )
        let match = MatchStore.shared.createMatch(settings: settings)
        MatchStore.shared.saveCurrentMatch()
        return match
    }

    private func refreshRostersForPitchSize() {
        let homeName = homeTeam.trimmingCharacters(in: .whitespacesAndNewlines)
        let awayName = awayTeam.trimmingCharacters(in: .whitespacesAndNewlines)
        homeRoster = MatchTeamRoster.empty(name: homeName, pitchSize: pitchSize)
        awayRoster = MatchTeamRoster.empty(name: awayName, pitchSize: pitchSize)
    }
}
