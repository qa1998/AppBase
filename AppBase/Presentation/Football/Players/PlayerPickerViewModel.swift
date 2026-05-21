//
//  PlayerPickerViewModel.swift
//  AppBase
//

import Combine
import Foundation

final class PlayerPickerViewModel: TIOViewModel<TIOLoadingTarget> {

    @Published var searchText = ""
    @Published var positionFilter: FootballPosition?
    @Published private(set) var players: [FootballPlayer] = []

    let slotIndex: Int

    init(slotIndex: Int) {
        self.slotIndex = slotIndex
        super.init()
        bindFilters()
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
        var list = FootballPlayer.catalog
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

    func select(_ player: FootballPlayer) {
        LineupStore.shared.assignPlayer(player, toSlot: slotIndex)
    }
}
