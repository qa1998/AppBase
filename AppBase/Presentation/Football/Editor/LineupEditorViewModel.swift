//
//  LineupEditorViewModel.swift
//  AppBase
//

import Combine
import Foundation

final class LineupEditorViewModel: TIOViewModel<TIOLoadingTarget> {

    @Published private(set) var lineup: FootballLineup
    @Published private(set) var hasTacticalStrokes = false
    @Published private(set) var canUndoStroke = false
    @Published private(set) var canRedoStroke = false
    @Published var selectedTool: EditorToolMode = .fields

    let slotTap = PassthroughSubject<Int, Never>()
    let benchTap = PassthroughSubject<Int, Never>()

    static let benchSlotCount = 5

    private var storeCancel: AnyCancellable?

    override init() {
        lineup = LineupStore.shared.currentLineup
        super.init()
        syncStrokeState()
        let store = LineupStore.shared
        storeCancel = Publishers.Merge(
            store.currentLineupDidChange.map { _ in () },
            store.tacticalDrawingDidChange.map { _ in () }
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
            guard let self else { return }
            self.lineup = store.currentLineup
            self.syncStrokeState()
        }
    }

    var displayTitle: String {
        lineup.displayTitle
    }

    var benchPlayers: [FootballPlayer] {
        lineup.benchPlayerIds.compactMap { id in
            guard !id.isEmpty else { return nil }
            return FootballPlayer.resolved(id: id)
        }
    }

    func benchPlayer(at index: Int) -> FootballPlayer? {
        guard lineup.benchPlayerIds.indices.contains(index) else {
            return nil
        }

        let id = lineup.benchPlayerIds[index]

        guard !id.isEmpty else {
            return nil
        }

        return FootballPlayer.resolved(id: id)
    }
    
    func prepareStrokeCommit() {
        LineupStore.shared.prepareStrokeCommit()
    }

    func strokeCommitted() {
        syncStrokeState()
    }

    func undoStroke() {
        LineupStore.shared.undoStroke()
    }

    func redoStroke() {
        LineupStore.shared.redoStroke()
    }

    func clearTacticalDrawings() {
        LineupStore.shared.clearTacticalDrawings()
    }

    func save() {
        LineupStore.shared.saveCurrentLineup()
        presentSuccess(L10n.Football.Editor.saved)
    }

    func importTeam(_ team: FootballTeam) {
        LineupStore.shared.importTeam(team)
        let name = team.name.isEmpty ? L10n.Football.Teams.unnamed : team.name
        presentSuccess(L10n.Football.Editor.importedTeam(name))
    }

    private func syncStrokeState() {
        let store = LineupStore.shared
        hasTacticalStrokes = !store.tacticalStrokes.isEmpty
        canUndoStroke = store.canUndoStroke
        canRedoStroke = store.canRedoStroke
    }
}
