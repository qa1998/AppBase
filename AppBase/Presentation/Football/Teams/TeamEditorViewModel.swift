//
//  TeamEditorViewModel.swift
//  AppBase
//

import Combine
import Foundation

final class TeamEditorViewModel: TIOViewModel<TIOLoadingTarget> {

    @Published private(set) var team: FootballTeam
    let slotTap = PassthroughSubject<Int, Never>()
    let benchTap = PassthroughSubject<Int, Never>()

    private var storeCancel: AnyCancellable?

    override init() {
        team = TeamStore.shared.currentTeam
        super.init()
        storeCancel = TeamStore.shared.currentTeamDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updated in
                self?.team = updated
            }
    }

    func updateName(_ name: String) {
        var copy = team
        copy.name = name
        TeamStore.shared.updateCurrent(copy)
    }

    func setPitchSize(_ size: MatchPitchSize) {
        TeamStore.shared.setPitchSize(size)
    }

    var canDeleteSavedTeam: Bool {
        TeamStore.shared.teams.contains { $0.id == team.id }
    }

    func save() {
        guard !team.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            presentError(message: L10n.Football.Teams.validationName)
            return
        }
        TeamStore.shared.saveCurrentTeam()
        presentSuccess(L10n.Football.Teams.saved)
    }

    func deleteSavedTeam() {
        guard canDeleteSavedTeam else { return }
        TeamStore.shared.deleteTeam(id: team.id)
    }
}
