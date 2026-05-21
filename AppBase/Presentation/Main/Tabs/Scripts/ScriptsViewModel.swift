//
//  ScriptsViewModel.swift
//  AppBase
//

import AdsKit
import BaseMVVM
import Combine
import UIKit

final class ScriptsViewModel: TIOViewModel<TIOLoadingTarget> {

    let statusText = CurrentValueSubject<String, Never>("")

    override func viewModelDidReady() {
        super.viewModelDidReady()
        updateStatus(L10n.Scripts.Ads.hint)
    }

    // MARK: - Banner

    func loadBanner() {
        updateStatus(L10n.Scripts.Ads.loading)
        AdsManager.shared.loadBanner { [weak self] success, error in
            self?.handleLoadResult(label: AdType.banner.description, success: success, error: error)
        }
    }

    func showBanner(from viewController: UIViewController) {
        updateStatus(L10n.Scripts.Ads.loading)
        AdsManager.shared.showBanner(from: viewController) { [weak self] success, error in
            self?.handleShowResult(label: AdType.banner.description, success: success, error: error)
        }
    }

    func hideBanner() {
        AdsManager.shared.destroy(adType: .banner)
        updateStatus(L10n.Scripts.Ads.success(AdType.banner.description + " hidden"))
    }

    // MARK: - Interstitial

    func loadInterstitial() {
        updateStatus(L10n.Scripts.Ads.loading)
        AdsManager.shared.loadInterstitial { [weak self] success, error in
            self?.handleLoadResult(label: AdType.interstitial.description, success: success, error: error)
        }
    }

    func showInterstitial(from viewController: UIViewController) {
        AdsManager.shared.showInterstitial(from: viewController) { [weak self] success, error in
            self?.handleShowResult(label: AdType.interstitial.description, success: success, error: error)
        }
    }

    // MARK: - Rewarded

    func loadRewarded() {
        updateStatus(L10n.Scripts.Ads.loading)
        AdsManager.shared.loadRewarded { [weak self] success, error in
            self?.handleLoadResult(label: AdType.rewarded.description, success: success, error: error)
        }
    }

    func showRewarded(from viewController: UIViewController) {
        AdsManager.shared.showRewarded(from: viewController) { [weak self] amount, type in
            self?.updateStatus(L10n.Scripts.Ads.reward(amount, type))
        } completion: { [weak self] success, error in
            self?.handleShowResult(label: AdType.rewarded.description, success: success, error: error)
        }
    }

    // MARK: - App open

    func loadAppOpen() {
        updateStatus(L10n.Scripts.Ads.loading)
        AdsManager.shared.loadAppOpen { [weak self] success, error in
            self?.handleLoadResult(label: AdType.appOpen.description, success: success, error: error)
        }
    }

    func showAppOpen(from viewController: UIViewController) {
        AdsManager.shared.showAppOpen(from: viewController) { [weak self] success, error in
            self?.handleShowResult(label: AdType.appOpen.description, success: success, error: error)
        }
    }

    // MARK: - Private

    private func handleLoadResult(label: String, success: Bool, error: Error?) {
        if success {
            updateStatus(L10n.Scripts.Ads.success(label + " loaded"))
            presentSuccess(L10n.Scripts.Ads.success(label + " loaded"))
        } else {
            let message = error?.localizedDescription ?? label
            updateStatus(L10n.Scripts.Ads.failed(message))
            presentError(message: L10n.Scripts.Ads.failed(message))
        }
    }

    private func handleShowResult(label: String, success: Bool, error: Error?) {
        if success {
            updateStatus(L10n.Scripts.Ads.success(label + " shown"))
            presentSuccess(L10n.Scripts.Ads.success(label + " shown"))
        } else {
            let message = error?.localizedDescription ?? label
            updateStatus(L10n.Scripts.Ads.failed(message))
            presentError(message: L10n.Scripts.Ads.failed(message))
        }
    }

    private func updateStatus(_ text: String) {
        statusText.send(L10n.Scripts.Ads.status(text))
    }
}
