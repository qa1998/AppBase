//
//  TIOViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import BaseMVVM
import Combine
import UIKit
import SnapKit

class TIOViewController<VM, Event: Hashable>: BaseViewController<VM>, LocalizationRefreshable
    where VM: TIOViewModel<Event> {

    var cancelBag = Set<AnyCancellable>()

    private var activeLoadingEvents = Set<Event>()

    /// Vùng shimmer mặc định. List VC override → `listView`; màn khác → `view` hoặc `TIOView` con.
    var shimmerContentView: UIView {
        view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindScreenTheme()
        bindLocalization()
        layoutIFSContentViewsIfNeeded()
    }

    private func bindLocalization() {
        LocalizationService.shared.$currentLanguage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshLocalization()
            }
            .store(in: &cancelBag)
    }

    /// Override để cập nhật `title`, label, … khi đổi ngôn ngữ.
    open func refreshLocalization() {}

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
            return
        }
        ThemeManager.shared.refreshPaletteIfNeeded()
    }

    private func bindScreenTheme() {
        bindTheme { [weak self] colors in
            self?.applyScreenTheme(colors)
            self?.refreshActiveShimmerIfNeeded()
        }
    }

    private func refreshActiveShimmerIfNeeded() {
        guard !activeLoadingEvents.isEmpty else { return }
        for event in activeLoadingEvents {
            applyShimmerLoading(true, on: shimmerViews(for: event))
        }
    }

    open func applyScreenTheme(_ colors: ThemeColors) {
        view.backgroundColor = colors.backgroundSecondary
    }

    override func onBind() {
        super.onBind()
        viewModel.trackLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] track in
                self?.handleTrackLoading(track)
            }
            .store(in: &cancelBag)

        viewModel.trackError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleTrackError(error)
            }
            .store(in: &cancelBag)

        viewModel.trackSuccess
            .receive(on: DispatchQueue.main)
            .sink { success in
                TIOEntryPresenter.showSuccess(success)
            }
            .store(in: &cancelBag)
    }

    /// Mặc định toast (SwiftEntryKit). Retry dialog: gọi `showTIOError(_:onRetry:)` trực tiếp.
    open func handleTrackError(_ error: TIOUserFacingError) {
        TIOEntryPresenter.showError(error)
    }

    open func shimmerViews(for event: Event) -> [UIView] {
        [shimmerContentView]
    }

    open func handleTrackLoading(_ track: TrackLoading<Event>) {
        if track.isLoading {
            activeLoadingEvents.insert(track.event)
        } else {
            activeLoadingEvents.remove(track.event)
        }
        let isLoading = activeLoadingEvents.contains(track.event)
        applyShimmerLoading(isLoading, on: shimmerViews(for: track.event))
    }

    func applyShimmerLoading(_ isLoading: Bool, on views: [UIView]) {
        let palette = ThemeManager.shared.palette
        for target in views {
            target.applyTIOShimmer(isLoading, palette: palette)
        }
    }

    func layoutIFSContentViewsIfNeeded() {
        for contentView in view.subviews where contentView is IFSContentView {
            contentView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    @objc func onBackPress() {
        navigationController?.popViewController(animated: true)
    }
}

typealias TIOScreenViewController<VM> = TIOViewController<VM, TIOLoadingTarget> where VM: TIOViewModel<TIOLoadingTarget>
