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

class TIOViewController<VM, Event: Hashable>: BaseViewController<VM> where VM: TIOViewModel<Event> {

    var cancelBag = Set<AnyCancellable>()

    private var activeLoadingEvents = Set<AnyHashable>()

    /// Vùng shimmer mặc định. List VC override → `listView`; màn khác → `view` hoặc `TIOView` con.
    var shimmerContentView: UIView {
        view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutIFSContentViewsIfNeeded()
    }

    override func onBind() {
        super.onBind()
        viewModel.trackLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] track in
                self?.handleTrackLoading(track)
            }
            .store(in: &cancelBag)
    }

    open func shimmerViews(for event: Event) -> [UIView] {
        [shimmerContentView]
    }

    open func handleTrackLoading(_ track: TrackLoading<Event>) {
        let key = AnyHashable(track.event)
        if track.isLoading {
            activeLoadingEvents.insert(key)
        } else {
            activeLoadingEvents.remove(key)
        }
        let isLoading = activeLoadingEvents.contains(key)
        applyShimmerLoading(isLoading, on: shimmerViews(for: track.event))
    }

    func applyShimmerLoading(_ isLoading: Bool, on views: [UIView]) {
        for target in views {
            target.setTemplateWithSubviews(
                isLoading,
                viewBackgroundColor: target.backgroundColor ?? .systemBackground
            )
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
