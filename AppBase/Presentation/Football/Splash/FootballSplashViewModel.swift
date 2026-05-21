//
//  FootballSplashViewModel.swift
//  AppBase
//

import Combine
import Foundation

final class FootballSplashViewModel: TIOViewModel<TIOLoadingTarget> {

    let didFinish = PassthroughSubject<Void, Never>()

    func start() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { [weak self] in
            self?.didFinish.send()
        }
    }
}
