//
//  PlayerPickerViewModel.swift
//  AppBase
//

import Combine
import Foundation

enum PlayerPickerTarget: Equatable {
    case lineupPitch(slot: Int)
    case lineupBench(index: Int)
    case teamPitch(slot: Int)
    case teamBench(index: Int)
}

enum PlayerPickerHighlight: Equatable {
    case none
    case assignedOnPitch
    case assignedOnBench
    case currentTarget
}

final class PlayerPickerViewModel: TIOViewModel<TIOLoadingTarget> {

    @Published var searchText = ""
    @Published var positionFilter: FootballPosition?
    @Published private(set) var players: [FootballPlayer] = []
    @Published private(set) var squadRevision = 0

    let target: PlayerPickerTarget

    init(target: PlayerPickerTarget) {
        self.target = target
        super.init()
        bindFilters()
        bindSquadChanges()
        PlayerStore.shared.playersDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                self.applyFilters(query: self.searchText, position: self.positionFilter)
            }
            .store(in: &cancellables)
    }

    /// Backward-compatible convenience for lineup pitch slot.
    convenience init(slotIndex: Int) {
        self.init(target: .lineupPitch(slot: slotIndex))
    }

    private func bindSquadChanges() {
        switch target {
        case .lineupPitch, .lineupBench:
            LineupStore.shared.currentLineupDidChange
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.refreshSquadState()
                }
                .store(in: &cancellables)
        case .teamPitch, .teamBench:
            TeamStore.shared.currentTeamDidChange
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.refreshSquadState()
                }
                .store(in: &cancellables)
        }
    }

    private func refreshSquadState() {
        squadRevision += 1
    }

    private func bindFilters() {
        Publishers.CombineLatest($searchText, $positionFilter)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] query, position in
                self?.applyFilters(query: query, position: position)
            }
            .store(in: &cancellables)
        applyFilters(query: "", position: nil)
    }

    private func applyFilters(query: String, position: FootballPosition?) {
        var list = PlayerStore.shared.allPlayers
        if let position {
            list = list.filter { $0.position == position }
        }
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        if !q.isEmpty {
            list = list.filter {
                $0.name.lowercased().contains(q)
                    || $0.club.lowercased().contains(q)
                    || $0.nation.lowercased().contains(q)
            }
        }
        players = list
    }

    func highlight(for player: FootballPlayer) -> PlayerPickerHighlight {
        switch target {
        case .lineupPitch(let slot):
            return lineupHighlight(playerId: player.id, targetPitchSlot: slot)
        case .lineupBench(let index):
            return lineupBenchHighlight(playerId: player.id, targetBenchIndex: index)
        case .teamPitch(let slot):
            return teamHighlight(playerId: player.id, targetPitchSlot: slot)
        case .teamBench(let index):
            return teamBenchHighlight(playerId: player.id, targetBenchIndex: index)
        }
    }

    var canClearTargetPosition: Bool {
        switch target {
        case .lineupPitch(let slot):
            guard slot >= 0, slot < LineupStore.shared.currentLineup.assignments.count else { return false }
            return LineupStore.shared.currentLineup.assignments[slot].player != nil
        case .lineupBench(let index):
            return LineupStore.shared.benchPlayer(at: index) != nil
        case .teamPitch(let slot):
            let setup = TeamStore.shared.currentTeam.activeSetup
            guard slot >= 0, slot < setup.assignments.count else { return false }
            return setup.assignments[slot].player != nil
        case .teamBench(let index):
            return TeamStore.shared.benchPlayer(at: index) != nil
        }
    }

    func select(_ player: FootballPlayer) {
        switch target {
        case .lineupPitch(let slot):
            LineupStore.shared.assignPlayerToSlot(player, pitchSlot: slot)
        case .lineupBench(let index):
            LineupStore.shared.assignPlayerToBench(player, benchIndex: index)
        case .teamPitch(let slot):
            TeamStore.shared.assignPlayerToSlot(player, pitchSlot: slot)
        case .teamBench(let index):
            TeamStore.shared.assignPlayerToBench(player, benchIndex: index)
        }
    }

    func clearTargetPosition() {
        switch target {
        case .lineupPitch(let slot):
            LineupStore.shared.clearPitchSlot(slot)
        case .lineupBench(let index):
            LineupStore.shared.setBenchPlayer(nil, at: index)
        case .teamPitch(let slot):
            TeamStore.shared.clearPitchSlot(slot)
        case .teamBench(let index):
            TeamStore.shared.setBenchPlayer(nil, at: index)
        }
    }

    private func lineupHighlight(playerId: String, targetPitchSlot: Int) -> PlayerPickerHighlight {
        let lineup = LineupStore.shared.currentLineup
        if targetPitchSlot >= 0,
           targetPitchSlot < lineup.assignments.count,
           lineup.assignments[targetPitchSlot].player?.id == playerId {
            return .currentTarget
        }
        if lineup.assignments.contains(where: { $0.player?.id == playerId }) {
            return .assignedOnPitch
        }
        if lineup.benchPlayerIds.contains(playerId) {
            return .assignedOnBench
        }
        return .none
    }

    private func lineupBenchHighlight(playerId: String, targetBenchIndex: Int) -> PlayerPickerHighlight {
        let lineup = LineupStore.shared.currentLineup
        if targetBenchIndex >= 0,
           targetBenchIndex < lineup.benchPlayerIds.count,
           lineup.benchPlayerIds[targetBenchIndex] == playerId {
            return .currentTarget
        }
        if lineup.benchPlayerIds.contains(playerId) {
            return .assignedOnBench
        }
        if lineup.assignments.contains(where: { $0.player?.id == playerId }) {
            return .assignedOnPitch
        }
        return .none
    }

    private func teamHighlight(playerId: String, targetPitchSlot: Int) -> PlayerPickerHighlight {
        let setup = TeamStore.shared.currentTeam.activeSetup
        if targetPitchSlot >= 0,
           targetPitchSlot < setup.assignments.count,
           setup.assignments[targetPitchSlot].player?.id == playerId {
            return .currentTarget
        }
        if setup.assignments.contains(where: { $0.player?.id == playerId }) {
            return .assignedOnPitch
        }
        if setup.benchPlayerIds.contains(playerId) {
            return .assignedOnBench
        }
        return .none
    }

    private func teamBenchHighlight(playerId: String, targetBenchIndex: Int) -> PlayerPickerHighlight {
        let setup = TeamStore.shared.currentTeam.activeSetup
        if targetBenchIndex >= 0,
           targetBenchIndex < setup.benchPlayerIds.count,
           setup.benchPlayerIds[targetBenchIndex] == playerId {
            return .currentTarget
        }
        if setup.benchPlayerIds.contains(playerId) {
            return .assignedOnBench
        }
        if setup.assignments.contains(where: { $0.player?.id == playerId }) {
            return .assignedOnPitch
        }
        return .none
    }
}
