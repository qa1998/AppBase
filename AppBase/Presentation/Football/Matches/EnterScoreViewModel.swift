//
//  EnterScoreViewModel.swift
//  AppBase
//

import Foundation

final class EnterScoreViewModel: TIOViewModel<TIOLoadingTarget> {

    private let editingMatchId: String?

    var homeTeam = ""
    var awayTeam = ""
    var homeGoals = 0
    var awayGoals = 0

    var isEditing: Bool { editingMatchId != nil }

    init(match: FootballMatch?) {
        editingMatchId = match?.id
        if let match {
            homeTeam = match.settings.homeTeam
            awayTeam = match.settings.awayTeam
            homeGoals = match.displayHomeGoals
            awayGoals = match.displayAwayGoals
        }
        super.init()
    }

    func save() -> Bool {
        let saved = MatchStore.shared.saveScoreEntry(
            id: editingMatchId,
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            homeGoals: homeGoals,
            awayGoals: awayGoals
        )
        if saved == nil {
            presentError(message: L10n.Football.Score.validationTeams)
            return false
        }
        return true
    }
}
