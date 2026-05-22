//
//  LineupShareViewModel.swift
//  AppBase
//

import Combine
import Foundation

enum LineupSharePitchMode: Int, CaseIterable {
    case flat
    case perspective3D
}

final class LineupShareViewModel: TIOViewModel<TIOLoadingTarget> {

    let lineup: FootballLineup
    @Published var pitchMode: LineupSharePitchMode = .flat

    init(lineup: FootballLineup) {
        self.lineup = lineup
        super.init()
    }
}
