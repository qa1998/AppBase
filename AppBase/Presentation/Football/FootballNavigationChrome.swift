//
//  FootballNavigationChrome.swift
//  AppBase
//

import UIKit

extension UINavigationController {

    func applyFootballNavigationChrome() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = FootballPalette.surface.withAlphaComponent(0.65)
        appearance.titleTextAttributes = [
            .foregroundColor: FootballPalette.textPrimary,
            .font: FootballPalette.title(17),
        ]
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.tintColor = FootballPalette.accentGreen
    }
}
