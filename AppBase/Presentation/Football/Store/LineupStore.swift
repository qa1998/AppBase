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

    private static let sampleSeedRemovedKey = "football.lineups.sampleRemoved.v1"

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
            applyDrawingState(from: currentLineup)
        } else {
            didLoadSnapshot = false
            savedLineups = []
            currentLineup = LineupStore.makeLineup(title: "", formation: .default)
            applyDrawingState(from: TacticalDrawingState.empty)
        }

        if didLoadSnapshot {
            migratePitchYAxisIfNeeded()
        } else {
            persist()
        }
        removeBundledSampleLineupsIfNeeded()
    }

    /// Xóa bộ 3 sơ đồ demo cũ (Dream Team / UCL / Counter Attack) đã lưu trên máy.
    private func removeBundledSampleLineupsIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: Self.sampleSeedRemovedKey) else { return }
        UserDefaults.standard.set(true, forKey: Self.sampleSeedRemovedKey)
        guard Self.looksLikeBundledSampleSeed(savedLineups) else { return }
        savedLineups = []
        currentLineup = LineupStore.makeLineup(title: "", formation: .default)
        undoStack.removeAll()
        redoStack.removeAll()
        applyDrawingState(from: TacticalDrawingState.empty)
        persist()
        notify()
    }

    private static func looksLikeBundledSampleSeed(_ lineups: [FootballLineup]) -> Bool {
        guard lineups.count == 3 else { return false }
        guard lineups.filter(\.isFavorite).count == 1,
              lineups.filter(\.isDraft).count == 1 else { return false }
        let formationNames = Set(lineups.compactMap { lineup in
            FootballFormation.catalog.first { $0.id == lineup.formationId }?.name
        })
        guard formationNames == Set(["4-3-3", "4-4-2", "3-5-2"]) else { return false }
        return lineups.allSatisfy { lineup in
            !lineup.assignments.isEmpty
                && lineup.assignments.allSatisfy { $0.player != nil }
        }
    }

    func createNewLineup(title: String = "") {
        currentLineup = LineupStore.makeLineup(title: title, formation: .default)
        undoStack.removeAll()
        redoStack.removeAll()
        applyDrawingState(from: TacticalDrawingState.empty)
        notify()
    }

    func resetAfterDataClear() {
        savedLineups = []
        currentLineup = LineupStore.makeLineup(title: "", formation: .default)
        undoStack.removeAll()
        redoStack.removeAll()
        tacticalStrokes = []
        strokeUndoStack = []
        strokeRedoStack = []
        tacticalLineOptions = .default
        pitchDisplayOptions = .default
        applyDrawingState(from: TacticalDrawingState.empty)
        persist()
        currentLineupDidChange.send(currentLineup)
        lineupsDidChange.send()
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

    /// Gán vào ô đích; gỡ khỏi ô khác nếu trùng — không hoán đổi cầu thủ bị thay.
    func assignPlayerToSlot(_ player: FootballPlayer, pitchSlot targetSlot: Int) {
        mutate { lineup in
            guard lineup.assignments.indices.contains(targetSlot) else { return }
            for index in lineup.assignments.indices where lineup.assignments[index].player?.id == player.id {
                lineup.assignments[index].player = nil
            }
            var ids = Self.normalizedBenchIds(lineup.benchPlayerIds)
            for index in ids.indices where ids[index] == player.id {
                ids[index] = ""
            }
            lineup.benchPlayerIds = ids
            lineup.assignments[targetSlot].player = player
        }
    }

    func assignPlayerToBench(_ player: FootballPlayer, benchIndex targetIndex: Int) {
        guard targetIndex >= 0, targetIndex < MatchTeamRoster.benchSlotCount else { return }
        mutate { lineup in
            for index in lineup.assignments.indices where lineup.assignments[index].player?.id == player.id {
                lineup.assignments[index].player = nil
            }
            var ids = Self.normalizedBenchIds(lineup.benchPlayerIds)
            for index in ids.indices where ids[index] == player.id {
                ids[index] = ""
            }
            ids[targetIndex] = player.id
            lineup.benchPlayerIds = ids
        }
    }

    func clearPitchSlot(_ slotIndex: Int) {
        assignPlayer(nil, toSlot: slotIndex)
    }

    func moveSlot(_ slotIndex: Int, to normalized: CGPoint) {
        mutate { lineup in
            guard lineup.assignments.indices.contains(slotIndex) else { return }
            lineup.assignments[slotIndex].normalizedPosition = normalized
        }
    }

    func setBench(_ playerIds: [String]) {
        mutate { $0.benchPlayerIds = Self.normalizedBenchIds(playerIds) }
    }

    func benchPlayer(at index: Int) -> FootballPlayer? {
        guard let id = currentLineup.benchPlayerIds[safe: index], !id.isEmpty else { return nil }
        return FootballPlayer.resolved(id: id)
    }

    func setBenchPlayer(_ player: FootballPlayer?, at index: Int) {
        guard index >= 0, index < MatchTeamRoster.benchSlotCount else { return }
        mutate { lineup in
            var ids = Self.normalizedBenchIds(lineup.benchPlayerIds)
            ids[index] = player?.id ?? ""
            lineup.benchPlayerIds = ids
        }
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

    /// Empty slots — user picks players in the editor.
    static func makeLineup(title: String, formation: FootballFormation) -> FootballLineup {
        let assignments = formation.slots.enumerated().map { index, point in
            PitchSlotAssignment(
                slotIndex: index,
                normalizedPosition: point,
                player: nil
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
            benchPlayerIds: normalizedBenchIds([]),
            updatedAt: Date()
        )
    }

}

private extension Array {

    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
