//
//  FootballScreenViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import UIKit

/// Dark tactical theme for all Football Lineup Builder screens.
class FootballScreenViewController<VM: TIOViewModel<TIOLoadingTarget>>: TIOViewController<VM, TIOLoadingTarget> {

    override func viewDidLoad() {
        super.viewDidLoad()
        applyFootballChrome()
        bindFootballThemeUpdates()
    }

    private func bindFootballThemeUpdates() {
        NotificationCenter.default.publisher(for: .footballThemeDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshFootballTheme()
            }
            .store(in: &cancelBag)
    }

    /// Override to refresh custom subviews when dark / light changes.
    open func refreshFootballTheme() {
        applyFootballChrome()
        applyScreenTheme(ThemeManager.shared.palette)
    }

    override func applyScreenTheme(_ colors: ThemeColors) {
        view.backgroundColor = FootballPalette.background
    }

    func applyFootballChrome() {
        view.backgroundColor = FootballPalette.background
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = FootballPalette.surface.withAlphaComponent(0.65)
        appearance.titleTextAttributes = [
            .foregroundColor: FootballPalette.textPrimary,
            .font: FootballPalette.title(17)
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = FootballPalette.accentGreen
    }
}
