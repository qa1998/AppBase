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

    var benchPlayers: [FootballPlayer] {
        lineup.benchPlayerIds.compactMap { id in
            FootballPlayer.resolved(id: id)
        }
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

    private func syncStrokeState() {
        let store = LineupStore.shared
        hasTacticalStrokes = !store.tacticalStrokes.isEmpty
        canUndoStroke = store.canUndoStroke
        canRedoStroke = store.canRedoStroke
    }
}
