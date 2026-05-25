//
//  FootballChromeRefreshable.swift
//  AppBase
//

import Combine
import UIKit

/// Bottom sheets / plain `UIViewController` that need Football palette + L10n refresh.
protocol FootballChromeRefreshable: AnyObject {
    func refreshFootballLocalization()
    func refreshFootballAppearance()
}

extension FootballChromeRefreshable where Self: UIViewController {

    func refreshFootballAppearance() {
        view.backgroundColor = FootballPalette.background
        refreshFootballLocalization()
    }

    func installFootballChromeObservers(storage: inout Set<AnyCancellable>) {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: .localizationDidChange),
            NotificationCenter.default.publisher(for: .footballThemeDidChange)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            guard let self else { return }
            self.refreshFootballAppearance()
        }
        .store(in: &storage)
    }
}
