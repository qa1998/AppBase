//
//  MatchTimelineModels.swift
//  AppBase
//

import Foundation

struct MatchTimelineEventRow: Equatable {
    let event: MatchEvent
    /// Icon / viền phút (thẻ vàng thứ 2 → đỏ; thẻ vàng đầu giữ vàng).
    let displayType: MatchEventType
    /// Thứ tự thẻ vàng của cầu thủ (1, 2, …); nil nếu không phải thẻ vàng.
    let yellowCardIndex: Int?
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
