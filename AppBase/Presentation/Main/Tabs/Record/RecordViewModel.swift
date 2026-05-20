//
//  RecordViewModel.swift
//  AppBase
//

import BaseMVVM
import Combine

class RecordViewModel: TIOViewModel<TIOLoadingTarget> {

    let pushTestScreen = PassthroughSubject<Int, Never>()

    func pushTestScreen(step: Int) {
        pushTestScreen.send(step)
    }
}
