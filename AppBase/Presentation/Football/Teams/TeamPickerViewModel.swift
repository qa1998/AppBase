//
//  TeamPickerViewModel.swift
//  AppBase
//

import Combine
import Foundation

final class TeamPickerViewModel: TIOViewModel<TIOLoadingTarget> {

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
}
