//
//  FootballDemoBannerAdPresenter.swift
//  AppBase
//

import AdsKit
import UIKit

/// Banner AdMob demo (test ID) cho các tab gốc Football — load/show qua `AdsManager`.
final class FootballDemoBannerAdPresenter {

    static let shared = FootballDemoBannerAdPresenter()

    /// Chiều cao banner chuẩn (320×50) — chừa inset nội dung phía trên.
    private let bannerBottomInset: CGFloat = 50

    private weak var hostViewController: UIViewController?

    private init() {}

    /// Gọi khi stack nav thay đổi: chỉ hiện banner trên root tab (1 VC).
    func updateForNavigationStack(_ navigationController: UINavigationController) {
        if navigationController.viewControllers.count == 1,
           let host = navigationController.viewControllers.first {
            present(on: host)
        } else {
            dismiss()
        }
    }

    func dismiss() {
        if let host = hostViewController {
            restoreInsets(on: host)
        }
        hostViewController = nil
        AdsManager.shared.destroy(adType: .banner)
    }

    private func present(on host: UIViewController) {
        if hostViewController === host {
            if AdsManager.shared.isBannerReady() {
                showBanner(on: host)
            } else {
                loadAndShow(on: host)
            }
            return
        }
        dismiss()
        hostViewController = host
        loadAndShow(on: host)
    }

    private func loadAndShow(on host: UIViewController) {
        AdsManager.shared.loadBanner { [weak self, weak host] success, _ in
            guard let self, let host, success else { return }
            DispatchQueue.main.async {
                guard self.hostViewController === host else { return }
                self.showBanner(on: host)
            }
        }
    }

    private func showBanner(on host: UIViewController) {
        AdsManager.shared.showBanner(from: host) { [weak self, weak host] _, _ in
            guard let self, let host, self.hostViewController === host else { return }
            self.applyInsets(on: host)
        }
    }

    private func applyInsets(on host: UIViewController) {
        host.additionalSafeAreaInsets.bottom = bannerBottomInset
    }

    private func restoreInsets(on host: UIViewController) {
        host.additionalSafeAreaInsets.bottom = 0
    }
}
