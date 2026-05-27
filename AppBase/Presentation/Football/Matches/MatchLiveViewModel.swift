//
//  MatchLiveViewModel.swift
//  AppBase
//

import Combine
import Foundation

final class MatchLiveViewModel: TIOViewModel<TIOLoadingTarget> {

    @Published private(set) var match: FootballMatch
    @Published private(set) var clockText = "00:00"
    @Published private(set) var phaseTitle = ""
    @Published private(set) var primaryButtonTitle: String?
    @Published private(set) var showQuickActions = false
    @Published private(set) var timelineSections: [MatchTimelineSection] = []

    private var timerCancellable: AnyCancellable?

    init(match: FootballMatch) {
        self.match = match
        super.init()
        syncElapsedFromClockAnchor()
        refreshPresentation()
        if isClockRunning {
            startClock()
        }
    }

    // MARK: - Match control

    func performPrimaryAction() {
        switch match.phase {
        case .scheduled:
            startFirstHalf()
        case .firstHalfStoppage:
            endFirstHalf()
        case .halftime:
            startSecondHalf()
        case .secondHalfStoppage:
            endSecondHalf()
        case .extraHalftime:
            startExtraSecond()
        case .extraSecondStoppage:
            finishAfterExtra()
        case .penaltyShootout:
            finishMatch()
        default:
            break
        }
    }

    func addEvent(_ type: MatchEventType, team: MatchTeamSide, player: FootballPlayer) {
        guard showQuickActions else { return }
        syncElapsedFromClockAnchor()
        let half = activeHalf
        let (minute, stoppage) = currentMinuteComponents()
        let event = MatchEvent(
            type: type,
            team: team,
            player: player,
            half: half,
            minute: minute,
            stoppageMinute: stoppage
        )
        match.events.append(event)
        commitAndRefresh()
    }

    /// Thẻ vàng 1 → icon/viền vàng; thẻ vàng 2 (cùng cầu thủ) → icon/viền đỏ. Thẻ đỏ trực tiếp → đỏ.
    private static func displayType(
        for event: MatchEvent,
        in events: [MatchEvent],
        settings: FootballMatchSettings
    ) -> MatchEventType {
        if event.type == .redCard { return .redCard }
        guard event.type == .yellowCard else { return event.type }
        guard let index = yellowCardIndex(for: event, in: events, settings: settings) else {
            return .yellowCard
        }
        return index >= 2 ? .redCard : .yellowCard
    }

    private static func yellowCardIndex(
        for event: MatchEvent,
        in events: [MatchEvent],
        settings: FootballMatchSettings
    ) -> Int? {
        guard event.type == .yellowCard else { return nil }
        let ordered = events.sorted { isTimelineOrder($0, before: $1, settings: settings) }
        let playerYellows = ordered.filter {
            $0.type == .yellowCard
                && $0.team == event.team
                && $0.playerId == event.playerId
        }
        guard let index = playerYellows.firstIndex(where: { $0.id == event.id }) else { return nil }
        return index + 1
    }

    private static func yellowCards(
        for team: MatchTeamSide,
        playerId: String,
        in events: [MatchEvent]
    ) -> [MatchEvent] {
        events.filter {
            $0.type == .yellowCard && $0.team == team && $0.playerId == playerId
        }
    }

    /// Ẩn thẻ đỏ trùng phút khi đã có ≥2 thẻ vàng (dữ liệu lưu nhầm lúc thêm vàng thứ 2).
    private static func shouldShowInTimeline(_ event: MatchEvent, in events: [MatchEvent]) -> Bool {
        guard event.type == .redCard else { return true }
        let yellows = yellowCards(for: event.team, playerId: event.playerId, in: events)
        guard yellows.count >= 2 else { return true }
        return !yellows.contains {
            $0.half == event.half
                && $0.minute == event.minute
                && $0.stoppageMinute == event.stoppageMinute
        }
    }

    /// Trên → dưới: phút tăng dần, cùng phút thì thêm trước ở trên.
    private static func isTimelineOrder(
        _ lhs: MatchEvent,
        before rhs: MatchEvent,
        settings: FootballMatchSettings
    ) -> Bool {
        let left = lhs.timelineMinute(settings: settings)
        let right = rhs.timelineMinute(settings: settings)
        if left.minute != right.minute { return left.minute < right.minute }
        if (left.stoppage ?? 0) != (right.stoppage ?? 0) {
            return (left.stoppage ?? 0) < (right.stoppage ?? 0)
        }
        return lhs.createdAt < rhs.createdAt
    }

    var showFinishMatchButton: Bool {
        switch match.phase {
        case .scheduled, .finished:
            return false
        default:
            return true
        }
    }

    func endMatchNow() {
        guard showFinishMatchButton else { return }
        finishMatch()
    }

    func isPlayerSentOff(playerId: String, team: MatchTeamSide) -> Bool {
        playerStatus(playerId: playerId, team: team).isSentOff
    }

    func playerStatus(playerId: String, team: MatchTeamSide) -> MatchLivePlayerStatus {
        var status = MatchLivePlayerStatus()
        for event in match.events where event.playerId == playerId && event.team == team {
            switch event.type {
            case .yellowCard:
                status.yellowCount += 1
            case .redCard:
                status.isSentOff = true
            case .goal:
                status.goalCount += 1
            case .substitution:
                status.substitutionMinute = event.minute
            default:
                break
            }
        }
        if status.yellowCount >= 2 {
            status.isSentOff = true
        }
        return status
    }

    func selectablePlayers(for side: MatchTeamSide) -> [FootballPlayer] {
        rosterPlayers(for: side).filter { !isPlayerSentOff(playerId: $0.id, team: side) }
    }

    func rosterPlayers(for side: MatchTeamSide) -> [FootballPlayer] {
        match.roster(for: side).allSquadPlayers
    }

    // MARK: - Timer

    private func startRunningPhase(
        _ phase: MatchPhase,
        clockBase: Int = 0
    ) {
        match.phase = phase
        match.clockBaseSeconds = clockBase
        match.segmentStartedAt = Date()
        syncElapsedFromClockAnchor()
        commitAndRefresh()
        startClock()
    }

    private func startFirstHalf() {
        startRunningPhase(.firstHalfRunning, clockBase: 0)
    }

    private func endFirstHalf() {
        stopClock()
        match.phase = .halftime
        match.clockBaseSeconds = 0
        match.segmentStartedAt = nil
        match.elapsedSeconds = 0
        commitAndRefresh()
    }

    private func startSecondHalf() {
        startRunningPhase(.secondHalfRunning, clockBase: 0)
    }

    private func startExtraSecond() {
        startRunningPhase(.extraSecondRunning, clockBase: 0)
    }

    private func endSecondHalf() {
        stopClock()
        match.segmentStartedAt = nil
        if match.settings.hasExtraTime {
            startRunningPhase(.extraFirstRunning, clockBase: 0)
        } else if match.settings.hasPenaltyShootout {
            match.phase = .penaltyShootout
            match.clockBaseSeconds = 0
            match.elapsedSeconds = 0
            commitAndRefresh()
        } else {
            finishMatch()
        }
    }

    private func finishAfterExtra() {
        stopClock()
        match.segmentStartedAt = nil
        if match.settings.hasPenaltyShootout {
            match.phase = .penaltyShootout
            match.clockBaseSeconds = 0
            match.elapsedSeconds = 0
            commitAndRefresh()
        } else {
            finishMatch()
        }
    }

    private func finishMatch() {
        stopClock()
        match.phase = .finished
        match.segmentStartedAt = nil
        commitAndRefresh()
        MatchStore.shared.saveCurrentMatch()
    }

    private func startClock() {
        stopClock()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func stopClock() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func tick() {
        guard isClockRunning else { return }
        syncElapsedFromClockAnchor()
        let limit = halfLimitSeconds
        if match.elapsedSeconds >= limit {
            enterStoppageTime()
        } else {
            commitAndRefresh()
        }
    }

    private func syncElapsedFromClockAnchor() {
        if let started = match.segmentStartedAt, isClockRunning {
            let delta = max(0, Int(Date().timeIntervalSince(started)))
            match.elapsedSeconds = match.clockBaseSeconds + delta
        }
    }

    private func enterStoppageTime() {
        syncElapsedFromClockAnchor()
        stopClock()
        let limit = halfLimitSeconds
        switch match.phase {
        case .firstHalfRunning:
            match.phase = .firstHalfStoppage
            match.elapsedSeconds = limit
            match.clockBaseSeconds = limit
        case .secondHalfRunning:
            match.phase = .secondHalfStoppage
            match.elapsedSeconds = limit
            match.clockBaseSeconds = limit
        case .extraFirstRunning:
            match.phase = .extraHalftime
            match.elapsedSeconds = 0
            match.clockBaseSeconds = 0
        case .extraSecondRunning:
            match.phase = .extraSecondStoppage
            match.elapsedSeconds = limit
            match.clockBaseSeconds = limit
        default:
            break
        }
        match.segmentStartedAt = nil
        commitAndRefresh()
    }

    private var isClockRunning: Bool {
        switch match.phase {
        case .firstHalfRunning, .secondHalfRunning, .extraFirstRunning, .extraSecondRunning:
            return true
        default:
            return false
        }
    }

    private var halfLimitSeconds: Int {
        let s = match.settings
        switch match.phase {
        case .firstHalfRunning, .firstHalfStoppage:
            return s.firstHalfMinutes * 60
        case .secondHalfRunning, .secondHalfStoppage:
            return s.secondHalfMinutes * 60
        case .extraFirstRunning:
            return s.extraTimeHalfMinutes * 60
        case .extraSecondRunning, .extraSecondStoppage:
            return s.extraTimeHalfMinutes * 60
        default:
            return 0
        }
    }

    private var activeHalf: MatchHalf {
        switch match.phase {
        case .scheduled, .firstHalfRunning, .firstHalfStoppage:
            return .first
        case .halftime, .secondHalfRunning, .secondHalfStoppage:
            return .second
        case .extraFirstRunning, .extraHalftime:
            return .extraFirst
        case .extraSecondRunning, .extraSecondStoppage:
            return .extraSecond
        case .penaltyShootout:
            return .penalties
        case .finished:
            return .second
        }
    }

    private func currentMinuteComponents() -> (minute: Int, stoppage: Int?) {
        let s = match.settings
        let elapsedMin = max(0, match.elapsedSeconds / 60)
        switch match.phase {
        case .firstHalfRunning:
            return (max(1, elapsedMin + 1), nil)
        case .firstHalfStoppage:
            let stoppage = max(1, (match.elapsedSeconds - s.firstHalfMinutes * 60) / 60 + 1)
            return (s.firstHalfMinutes, stoppage)
        case .secondHalfRunning:
            return (s.firstHalfMinutes + max(1, elapsedMin + 1), nil)
        case .secondHalfStoppage:
            let stoppage = max(1, (match.elapsedSeconds - s.secondHalfMinutes * 60) / 60 + 1)
            return (s.firstHalfMinutes + s.secondHalfMinutes, stoppage)
        case .extraFirstRunning:
            return (s.firstHalfMinutes + s.secondHalfMinutes + max(1, elapsedMin + 1), nil)
        case .extraSecondRunning:
            let base = s.firstHalfMinutes + s.secondHalfMinutes + s.extraTimeHalfMinutes
            return (base + max(1, elapsedMin + 1), nil)
        case .extraSecondStoppage:
            let base = s.firstHalfMinutes + s.secondHalfMinutes + s.extraTimeHalfMinutes
            let stoppage = max(1, (match.elapsedSeconds - s.extraTimeHalfMinutes * 60) / 60 + 1)
            return (base + s.extraTimeHalfMinutes, stoppage)
        case .penaltyShootout:
            return (s.firstHalfMinutes + s.secondHalfMinutes, nil)
        default:
            return (1, nil)
        }
    }

    // MARK: - Presentation

    private func commitAndRefresh() {
        MatchStore.shared.updateCurrent(match)
        refreshPresentation()
    }

    private func refreshPresentation() {
        clockText = formatClock()
        phaseTitle = phaseTitle(for: match.phase)
        primaryButtonTitle = primaryButtonTitle(for: match.phase)
        showQuickActions = isLivePhase(match.phase) && match.phase != .extraHalftime
        timelineSections = buildTimeline()
    }

    private func formatClock() -> String {
        let seconds = cumulativeMatchSeconds()
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    /// Đồng hồ trận — tích lũy từ kickoff (không reset mỗi hiệp).
    private func cumulativeMatchSeconds() -> Int {
        let s = match.settings
        let segment = match.elapsedSeconds
        switch match.phase {
        case .scheduled:
            return 0
        case .firstHalfRunning, .firstHalfStoppage:
            return segment
        case .halftime:
            return s.firstHalfMinutes * 60
        case .secondHalfRunning, .secondHalfStoppage:
            return s.firstHalfMinutes * 60 + segment
        case .extraHalftime:
            return (s.firstHalfMinutes + s.secondHalfMinutes) * 60
        case .extraFirstRunning:
            return (s.firstHalfMinutes + s.secondHalfMinutes) * 60 + segment
        case .extraSecondRunning, .extraSecondStoppage:
            return (s.firstHalfMinutes + s.secondHalfMinutes + s.extraTimeHalfMinutes) * 60 + segment
        case .penaltyShootout, .finished:
            let extra = s.hasExtraTime ? s.extraTimeHalfMinutes * 2 * 60 : 0
            return (s.firstHalfMinutes + s.secondHalfMinutes) * 60 + extra + segment
        }
    }

    private func isLivePhase(_ phase: MatchPhase) -> Bool {
        switch phase {
        case .firstHalfRunning, .firstHalfStoppage,
             .secondHalfRunning, .secondHalfStoppage,
             .extraFirstRunning, .extraSecondRunning, .extraSecondStoppage,
             .penaltyShootout:
            return true
        default:
            return false
        }
    }

    private func phaseTitle(for phase: MatchPhase) -> String {
        switch phase {
        case .scheduled: return L10n.Football.Match.Phase.scheduled
        case .firstHalfRunning: return L10n.Football.Match.Phase.firstHalf
        case .firstHalfStoppage: return L10n.Football.Match.Phase.firstHalfStoppage
        case .halftime: return L10n.Football.Match.Phase.halftime
        case .secondHalfRunning: return L10n.Football.Match.Phase.secondHalf
        case .secondHalfStoppage: return L10n.Football.Match.Phase.secondHalfStoppage
        case .extraFirstRunning: return L10n.Football.Match.Phase.extraFirst
        case .extraHalftime: return L10n.Football.Match.Phase.extraHalftime
        case .extraSecondRunning: return L10n.Football.Match.Phase.extraSecond
        case .extraSecondStoppage: return L10n.Football.Match.Phase.extraSecondStoppage
        case .penaltyShootout: return L10n.Football.Match.Phase.penalties
        case .finished: return L10n.Football.Match.Phase.finished
        }
    }

    private func primaryButtonTitle(for phase: MatchPhase) -> String? {
        switch phase {
        case .scheduled: return L10n.Football.Match.Action.startMatch
        case .firstHalfStoppage: return L10n.Football.Match.Action.endFirstHalf
        case .halftime: return L10n.Football.Match.Action.startSecondHalf
        case .secondHalfStoppage: return L10n.Football.Match.Action.endMatch
        case .extraHalftime: return L10n.Football.Match.Action.startExtraSecond
        case .extraSecondStoppage: return L10n.Football.Match.Action.endMatch
        case .penaltyShootout: return L10n.Football.Match.Action.endPenalties
        default: return nil
        }
    }

    private func buildTimeline() -> [MatchTimelineSection] {
        let scoreByEventId = runningScoresByEventId()
        let order: [MatchHalf] = [.first, .second, .extraFirst, .extraSecond, .penalties]
        let settings = match.settings
        return order.compactMap { half in
            let events = match.events
                .filter { $0.half == half && Self.shouldShowInTimeline($0, in: match.events) }
                .sorted { MatchLiveViewModel.isTimelineOrder($0, before: $1, settings: settings) }
            guard !events.isEmpty else { return nil }
            let rows = events.enumerated().map { index, event in
                MatchTimelineEventRow(
                    event: event,
                    displayType: Self.displayType(for: event, in: match.events, settings: settings),
                    yellowCardIndex: Self.yellowCardIndex(
                        for: event,
                        in: match.events,
                        settings: settings
                    ),
                    scoreText: scoreByEventId[event.id],
                    isFirstInSection: index == 0,
                    isLastInSection: index == events.count - 1
                )
            }
            return MatchTimelineSection(
                half: half,
                title: halfTitle(half),
                durationText: halfDurationText(half),
                rows: rows
            )
        }
    }

    private func runningScoresByEventId() -> [String: String] {
        let settings = match.settings
        let chronological = match.events.sorted { lhs, rhs in
            if lhs.half.rawValue != rhs.half.rawValue { return lhs.half.rawValue < rhs.half.rawValue }
            let left = lhs.timelineMinute(settings: settings)
            let right = rhs.timelineMinute(settings: settings)
            if left.minute != right.minute { return left.minute < right.minute }
            return (left.stoppage ?? 0) < (right.stoppage ?? 0)
        }
        var home = 0
        var away = 0
        var result: [String: String] = [:]
        for event in chronological where event.type == .goal {
            switch event.team {
            case .home: home += 1
            case .away: away += 1
            case .neutral: break
            }
            result[event.id] = "\(home)-\(away)"
        }
        if match.phase == .finished, let last = chronological.last(where: { $0.type == .goal }) {
            result[last.id] = result[last.id] ?? match.scoreLine
        }
        return result
    }

    private func halfDurationText(_ half: MatchHalf) -> String {
        let s = match.settings
        let minutes: Int
        switch half {
        case .first: minutes = s.firstHalfMinutes
        case .second: minutes = s.secondHalfMinutes
        case .extraFirst, .extraSecond: minutes = s.extraTimeHalfMinutes
        case .penalties: minutes = 0
        }
        return String(format: "%02d:00", minutes)
    }

    private func halfTitle(_ half: MatchHalf) -> String {
        switch half {
        case .first: return L10n.Football.Match.Half.first
        case .second: return L10n.Football.Match.Half.second
        case .extraFirst: return L10n.Football.Match.Half.extraFirst
        case .extraSecond: return L10n.Football.Match.Half.extraSecond
        case .penalties: return L10n.Football.Match.Half.penalties
        }
    }

    func persistState() {
        syncElapsedFromClockAnchor()
        MatchStore.shared.updateCurrent(match)
    }
}
