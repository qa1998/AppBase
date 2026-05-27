//
//  TeamPickerViewModel.swift
//  AppBase
//

import Combine
import Foundation

final class TeamPickerViewModel: TIOViewModel<TIOLoadingTarget> {

    @Published private(set) var teams: [FootballTeam] = []

    /// Khi tạo trận — chỉ hiện đội đã lưu (có tên); gợi ý cỡ sân qua `pitchSize`.
    let pitchSize: MatchPitchSize?

    private var storeCancel: AnyCancellable?

    init(pitchSize: MatchPitchSize? = nil) {
        self.pitchSize = pitchSize
        super.init()
        reload()
        storeCancel = TeamStore.shared.teamsDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.reload()
            }
    }

    func reload() {
        teams = TeamStore.shared.teams
            .filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    func deleteTeam(_ team: FootballTeam) {
        TeamStore.shared.deleteTeam(id: team.id)
        reload()
    }
}
