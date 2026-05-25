//
//  FootballScreenViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import UIKit

/// Dark tactical theme for all Football Lineup Builder screens.
class FootballScreenViewController<VM: TIOViewModel<TIOLoadingTarget>>: TIOViewController<VM, TIOLoadingTarget> {
    
    override var navSetting: NavigationSetting {
        return super.navSetting
    }
    
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
        refreshLocalization()
        refreshNavigationLocalization()
    }

    override func refreshNavigationLocalization() {
        let setting = navSetting
        if setting.useLargeTitleView {
            setupNavigation(setting)
        } else if let title = setting.title {
            self.title = title
            navigationItem.title = title
        }
        applyNavigationItemTheme(
            titleColor: FootballPalette.textPrimary,
            barTintColor: FootballPalette.accentGreen
        )
    }

    override func applyScreenTheme(_ colors: ThemeColors) {
        view.backgroundColor = FootballPalette.background
        applyNavigationItemTheme(
            titleColor: FootballPalette.textPrimary,
            barTintColor: FootballPalette.accentGreen
        )
    }

    func applyFootballChrome() {
        view.backgroundColor = FootballPalette.background
        let isLight = ThemeManager.shared.mode == .light
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(
            style: isLight ? .systemUltraThinMaterialLight : .systemUltraThinMaterialDark
        )
        appearance.backgroundColor = FootballPalette.background
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: FootballPalette.textPrimary,
            .font: FootballPalette.title(17)
        ]
        appearance.titleTextAttributes = titleAttributes
        appearance.largeTitleTextAttributes = [
            .foregroundColor: FootballPalette.textPrimary,
            .font: FootballPalette.title(24)
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = FootballPalette.accentGreen
        applyNavigationItemTheme(
            titleColor: FootballPalette.textPrimary,
            barTintColor: FootballPalette.accentGreen
        )
    }
}
