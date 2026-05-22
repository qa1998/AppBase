//
//  LineupStore.swift
//  AppBase
//

import Combine
import CoreGraphics
import Foundation

/// In-memory lineup state with undo / redo for the editor.
final class LineupStore {

    static let shared = LineupStore()

    let lineupsDidChange = PassthroughSubject<Void, Never>()
    let currentLineupDidChange = PassthroughSubject<FootballLineup, Never>()
    let tacticalDrawingDidChange = PassthroughSubject<Void, Never>()

    private(set) var savedLineups: [FootballLineup] = []
    private(set) var currentLineup: FootballLineup

    private var undoStack: [FootballLineup] = []
    private var redoStack: [FootballLineup] = []

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    private(set) var tacticalStrokes: [TacticalStroke] = []
    private(set) var strokeUndoStack: [[TacticalStroke]] = []
    private(set) var strokeRedoStack: [[TacticalStroke]] = []
    var tacticalLineOptions: TacticalLineOptions = .default
    var pitchDisplayOptions: PitchDisplayOptions = .default

    var canUndoStroke: Bool { !strokeUndoStack.isEmpty }
    var canRedoStroke: Bool { !strokeRedoStack.isEmpty }

    private init() {
        let didLoadSnapshot: Bool
        if let snapshot = DataStore.shared.value(
            forKey: .footballLineups,
            type: FootballLineupsSnapshot.self
        ), !snapshot.savedLineups.isEmpty {
            didLoadSnapshot = true
            savedLineups = snapshot.savedLineups
            currentLineup = snapshot.currentLineup
            tacticalStrokes = snapshot.tacticalStrokes
            strokeUndoStack = snapshot.strokeUndoStack
            strokeRedoStack = snapshot.strokeRedoStack
            tacticalLineOptions = snapshot.tacticalLineOptions
            pitchDisplayOptions = snapshot.pitchDisplayOptions
        } else {
            didLoadSnapshot = false
            savedLineups = LineupStore.sampleLineups()
            currentLineup = savedLineups[0]
            applyDrawingState(from: currentLineup)
        }

        if didLoadSnapshot {
            migratePitchYAxisIfNeeded()
        } else {
            persist()
        }
    }

    static func sampleLineups() -> [FootballLineup] {
        let eleven = FootballFormation.formations(playerCount: 11)
        let formations: [FootballFormation] = [
            eleven.first { $0.name == "4-3-3" } ?? .default,
            eleven.first { $0.name == "4-4-2" } ?? .default,
            eleven.first { $0.name == "3-5-2" } ?? .default,
        ]
        let styles: [TacticalStyle] = [.attacking, .balanced, .defensive]
        let titles = [
            L10n.Football.Lineups.Sample.dreamTeam,
            L10n.Football.Lineups.Sample.uclFinal,
            L10n.Football.Lineups.Sample.counterAttack,
        ]
        let offsets: [TimeInterval] = [-7200, -86_400, -259_200]
        return zip(titles.indices, titles).map { index, title in
            var lineup = makeLineup(title: title, formation: formations[index])
            lineup.tacticalStyle = styles[index]
            lineup.isFavorite = index == 0
            lineup.isDraft = index == 2
            lineup.updatedAt = Date().addingTimeInterval(offsets[index])
            return lineup
        }
    }

    func createNewLineup(title: String = "") {
        currentLineup = LineupStore.makeLineup(title: title, formation: .default)
        undoStack.removeAll()
        redoStack.removeAll()
        applyDrawingState(from: TacticalDrawingState.empty)
        notify()
    }

    func loadLineup(_ lineup: FootballLineup) {
        pushUndoSnapshot()
        currentLineup = lineup
        redoStack.removeAll()
        applyDrawingState(from: lineup)
        notify()
    }

    func applyFormation(_ formation: FootballFormation) {
        mutate { lineup in
            lineup.formationId = formation.id
            lineup.assignments = Self.assignments(
                from: formation,
                preservingPlayersFrom: lineup.assignments
            )
        }
    }

    /// Loads a saved team roster + formation into the current lineup for tactical editing.
    func importTeam(_ team: FootballTeam, pitchSize: MatchPitchSize? = nil) {
        let size = pitchSize ?? team.activePitchSize
        let setup = team.setup(for: size)
        let formation = team.formation(for: size)

        mutate { lineup in
            if !team.name.isEmpty {
                lineup.title = team.name
            }
            lineup.formationId = formation.id
            lineup.assignments = Self.assignments(
                from: formation,
                preservingPlayersFrom: setup.assignments
            )
            lineup.benchPlayerIds = Self.normalizedBenchIds(setup.benchPlayerIds)
        }
        clearTacticalDrawings()
    }

    func assignPlayer(_ player: FootballPlayer?, toSlot slotIndex: Int) {
        mutate { lineup in
            guard lineup.assignments.indices.contains(slotIndex) else { return }
            lineup.assignments[slotIndex].player = player
        }
    }

    func moveSlot(_ slotIndex: Int, to normalized: CGPoint) {
        mutate { lineup in
            guard lineup.assignments.indices.contains(slotIndex) else { return }
            lineup.assignments[slotIndex].normalizedPosition = normalized
        }
    }

    func setBench(_ playerIds: [String]) {
        mutate { $0.benchPlayerIds = playerIds }
    }

    func updateCurrentLineupTitle(_ title: String) {
        pushUndoSnapshot()
        var copy = currentLineup
        copy.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        copy.updatedAt = Date()
        currentLineup = copy
        redoStack.removeAll()
        syncSavedLineupRecordFromCurrent()
        notify()
    }

    /// Mirrors lightweight edits on `currentLineup` into `savedLineups` (e.g. title from settings).
    private func syncSavedLineupRecordFromCurrent() {
        guard let index = savedLineups.firstIndex(where: { $0.id == currentLineup.id }) else { return }
        savedLineups[index].title = currentLineup.title
        savedLineups[index].updatedAt = currentLineup.updatedAt
    }

    func updateLineupMetadata(id: String, isFavorite: Bool? = nil, isDraft: Bool? = nil) {
        guard let index = savedLineups.firstIndex(where: { $0.id == id }) else { return }
        if let isFavorite { savedLineups[index].isFavorite = isFavorite }
        if let isDraft { savedLineups[index].isDraft = isDraft }
        notify()
    }

    func saveCurrentLineup() {
        var copy = currentLineup
        copy.updatedAt = Date()
        copy.tacticalDrawing = TacticalDrawingState(
            strokes: tacticalStrokes,
            undoStack: strokeUndoStack,
            redoStack: strokeRedoStack
        )
        copy.tacticalLineOptions = tacticalLineOptions
        copy.pitchDisplayOptions = pitchDisplayOptions
        currentLineup = copy
        if let index = savedLineups.firstIndex(where: { $0.id == currentLineup.id }) {
            savedLineups[index] = currentLineup
        } else {
            savedLineups.insert(currentLineup, at: 0)
        }
        persist()
        notify()
    }

    // MARK: - Tactical drawing

    func prepareStrokeCommit() {
        strokeUndoStack.append(tacticalStrokes)
        strokeRedoStack.removeAll()
        trimStrokeHistory()
        notifyDrawing()
    }

    func setTacticalStrokes(_ strokes: [TacticalStroke]) {
        tacticalStrokes = strokes
        notifyDrawing()
    }

    func undoStroke() {
        guard let previous = strokeUndoStack.popLast() else { return }
        strokeRedoStack.append(tacticalStrokes)
        tacticalStrokes = previous
        notifyDrawing()
    }

    func redoStroke() {
        guard let next = strokeRedoStack.popLast() else { return }
        strokeUndoStack.append(tacticalStrokes)
        tacticalStrokes = next
        notifyDrawing()
    }

    func clearTacticalDrawings() {
        guard !tacticalStrokes.isEmpty else { return }
        strokeUndoStack.removeAll()
        strokeRedoStack.removeAll()
        tacticalStrokes.removeAll()
        notifyDrawing()
    }

    func undo() {
        guard let previous = undoStack.popLast() else { return }
        redoStack.append(currentLineup)
        currentLineup = previous
        notify()
    }

    func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(currentLineup)
        currentLineup = next
        notify()
    }

    // MARK: - Private

    private func mutate(_ block: (inout FootballLineup) -> Void) {
        pushUndoSnapshot()
        var copy = currentLineup
        block(&copy)
        currentLineup = copy
        redoStack.removeAll()
        notify()
    }

    private func pushUndoSnapshot() {
        undoStack.append(currentLineup)
        if undoStack.count > 30 { undoStack.removeFirst() }
    }

    private func applyDrawingState(from lineup: FootballLineup) {
        applyDrawingState(from: lineup.tacticalDrawing)
        tacticalLineOptions = lineup.tacticalLineOptions
        pitchDisplayOptions = lineup.pitchDisplayOptions
    }

    private func applyDrawingState(from state: TacticalDrawingState) {
        tacticalStrokes = state.strokes
        strokeUndoStack = state.undoStack
        strokeRedoStack = state.redoStack
        notifyDrawing()
    }

    private func trimStrokeHistory() {
        let limit = 30
        if strokeUndoStack.count > limit {
            strokeUndoStack.removeFirst(strokeUndoStack.count - limit)
        }
    }

    private func notifyDrawing() {
        persist()
        tacticalDrawingDidChange.send()
    }

    private func notify() {
        persist()
        currentLineupDidChange.send(currentLineup)
        lineupsDidChange.send()
    }

    private func migratePitchYAxisIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: PitchFormationGridLayout.gridLayoutLineupsMigrationKey) else { return }
        savedLineups = savedLineups.map { Self.realignLineupToGrid($0) }
        currentLineup = Self.realignLineupToGrid(currentLineup)
        if FormationCatalog.isPitchYAxisInverted(currentLineup.assignments) {
            tacticalStrokes = tacticalStrokes.map(FormationCatalog.flipStroke)
            strokeUndoStack = strokeUndoStack.map { $0.map(FormationCatalog.flipStroke) }
            strokeRedoStack = strokeRedoStack.map { $0.map(FormationCatalog.flipStroke) }
        }
        UserDefaults.standard.set(true, forKey: PitchFormationGridLayout.gridLayoutLineupsMigrationKey)
        persist()
    }

    private static func realignLineupToGrid(_ lineup: FootballLineup) -> FootballLineup {
        var copy = lineup
        copy.assignments = PitchFormationGridLayout.realignAssignments(copy.assignments, formation: copy.formation)
        return copy
    }

    private func persist() {
        let snapshot = FootballLineupsSnapshot(
            savedLineups: savedLineups,
            currentLineup: currentLineup,
            tacticalStrokes: tacticalStrokes,
            strokeUndoStack: strokeUndoStack,
            strokeRedoStack: strokeRedoStack,
            tacticalLineOptions: tacticalLineOptions,
            pitchDisplayOptions: pitchDisplayOptions
        )
        DataStore.shared.set(snapshot, forKey: .footballLineups)
    }

    private static func assignments(
        from formation: FootballFormation,
        preservingPlayersFrom source: [PitchSlotAssignment]
    ) -> [PitchSlotAssignment] {
        formation.slots.enumerated().map { index, point in
            PitchSlotAssignment(
                slotIndex: index,
                normalizedPosition: point,
                player: source[safe: index]?.player
            )
        }
    }

    private static func normalizedBenchIds(_ ids: [String]) -> [String] {
        var bench = Array(ids.prefix(MatchTeamRoster.benchSlotCount))
        while bench.count < MatchTeamRoster.benchSlotCount {
            bench.append("")
        }
        return bench
    }

    static func makeLineup(title: String, formation: FootballFormation) -> FootballLineup {
        let players = FootballPlayer.catalog
        let assignments = formation.slots.enumerated().map { index, point in
            PitchSlotAssignment(
                slotIndex: index,
                normalizedPosition: point,
                player: index < players.count ? players[index] : nil
            )
        }
        return FootballLineup(
            id: UUID().uuidString,
            title: title,
            formationId: formation.id,
            tacticalStyle: .balanced,
            isFavorite: false,
            isDraft: false,
            assignments: assignments,
            benchPlayerIds: Array(players.dropFirst(formation.slots.count).prefix(5).map(\.id)),
            updatedAt: Date()
        )
    }
}

private extension Array {

    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
