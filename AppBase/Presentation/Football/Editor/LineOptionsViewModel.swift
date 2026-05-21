//
//  LineOptionsViewModel.swift
//  AppBase
//

import Combine
import Foundation

final class LineOptionsViewModel: TIOViewModel<TIOLoadingTarget> {

    @Published private(set) var draft: TacticalLineOptions

    init(options: TacticalLineOptions) {
        draft = options
        super.init()
    }

    func mutateDraft(_ block: (inout TacticalLineOptions) -> Void) {
        var copy = draft
        block(&copy)
        draft = copy
    }
}
