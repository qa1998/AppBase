//
//  MatchTimelineModels.swift
//  AppBase
//

import Foundation

struct MatchTimelineEventRow: Equatable {
    let event: MatchEvent
    let scoreText: String?
    let isFirstInSection: Bool
    let isLastInSection: Bool
}

struct MatchTimelineSection: Equatable {
    let half: MatchHalf
    let title: String
    let durationText: String
    let rows: [MatchTimelineEventRow]
}
