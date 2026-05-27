//
//  MatchLiveModels.swift
//  AppBase
//

import Foundation

/// Badge / trạng thái cầu thủ trên sơ đồ đội hình live.
struct MatchLivePlayerStatus: Equatable {
    var yellowCount: Int = 0
    var isSentOff: Bool = false
    var goalCount: Int = 0
    /// Phút thay người (nếu có sự kiện đổi).
    var substitutionMinute: Int?
}
