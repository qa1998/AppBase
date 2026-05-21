//
//  MyTeamsViewModel.swift
//  AppBase
//

import Combine
import Foundation

final class MyTeamsViewModel: TIOViewModel<TIOLoadingTarget> {

    @Published private(set) var teams: [FootballTeam] = []

    private var storeCancel: AnyCancellable?

    override init() {
        super.init()
        reload()
        storeCancel = TeamStore.shared.teamsDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.reload()
            }
    }

    func reload() {
        teams = TeamStore.shared.teams.sorted { $0.updatedAt > $1.updatedAt }
    }

    func openTeam(_ team: FootballTeam) {
        TeamStore.shared.loadTeam(team)
    }

    func createTeam() {
        TeamStore.shared.createNewTeam()
    }

    func deleteTeam(_ team: FootballTeam) {
        TeamStore.shared.deleteTeam(id: team.id)
        reload()
    }
}
