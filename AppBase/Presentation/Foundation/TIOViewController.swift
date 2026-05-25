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

struct NavigationSetting {
    var title: String? = nil
    var titleColor: UIColor = FootballPalette.textPrimary
    var backImage: String = "ic_arrow_left"
    var navigationShadow: UIImage? = nil
    var rightButtons: [UIBarButtonItem]? = nil
    var leftButtons: [UIBarButtonItem]? = nil
    var useLargeTitleView: Bool = false
}

extension NavigationSetting {
    
    static func singleTitle(
        _ title: String,
        rightItems: [UIBarButtonItem] = [],
        leftItems: [UIBarButtonItem] = []
    ) -> Self {
        return NavigationSetting(
            title: title,
            rightButtons: rightItems,
            leftButtons: leftItems
        )
    }
    
    static func largeTitle(
        _ title: String,
        subtitle: String? = nil,
        rightItems: [UIBarButtonItem] = [],
        leftItems: [UIBarButtonItem] = []
    ) -> Self {
        NavigationSetting(
            title: title,
            rightButtons: rightItems,
            leftButtons: leftItems,
            useLargeTitleView: true
        )
    }
}

class TIOViewController<VM, Event: Hashable>: BaseViewController<VM>, UIGestureRecognizerDelegate, LocalizationRefreshable, NavigationLocalizationRefresh
where VM: TIOViewModel<Event> {
    
    var cancelBag = Set<AnyCancellable>()
    
    private var activeLoadingEvents = Set<Event>()
    
    private weak var navigationTitleLabel: UILabel?
    private weak var navigationBackButton: UIButton?
    
    /// Vùng shimmer mặc định. List VC override → `listView`; màn khác → `view` hoặc `TIOView` con.
    var shimmerContentView: UIView {
        view
    }
    
    var navSetting: NavigationSetting {
        return NavigationSetting()
    }
    
    private lazy var dismissKeyboardGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleDismissKeyboard)
        )
        
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        
        return gesture
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation(navSetting)
        bindScreenTheme()
        bindLocalization()
        layoutIFSContentViewsIfNeeded()
        setupKeyboardDismissGesture()
    }
    
    private func setupKeyboardDismissGesture() {
        view.addGestureRecognizer(dismissKeyboardGesture)
    }
    
    @objc private func handleDismissKeyboard() {
        view.endEditing(true)
    }
    
    private func bindLocalization() {
        LocalizationService.shared.$currentLanguage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshLocalization()
                self?.refreshNavigationLocalization()
            }
            .store(in: &cancelBag)
    }
    
    /// Override để cập nhật `title`, label, … khi đổi ngôn ngữ.
    open func refreshLocalization() {}

    /// Cập nhật custom large title (`useLargeTitleView`) hoặc `navigationItem.title` từ `navSetting`.
    open func refreshNavigationLocalization() {
        let setting = navSetting
        if setting.useLargeTitleView {
            setupNavigation(setting)
        } else if let title = setting.title {
            self.title = title
            navigationItem.title = title
        }
    }
    
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
        applyNavigationItemTheme(titleColor: colors.textPrimary, barTintColor: colors.textPrimary)
    }

    /// Custom large title (`useLargeTitleView`) — cập nhật màu khi đổi theme (subclass có thể dùng palette riêng).
    open func applyNavigationItemTheme(titleColor: UIColor, barTintColor: UIColor? = nil) {
        navigationTitleLabel?.textColor = titleColor
        navigationBackButton?.tintColor = titleColor

        if let barTintColor {
            navigationController?.navigationBar.tintColor = barTintColor
        }

        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: titleColor
        ]
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: titleColor
        ]

        navigationItem.leftBarButtonItems?.forEach { item in
            item.tintColor = titleColor
            if let label = item.customView as? UILabel {
                label.textColor = titleColor
            } else if let button = item.customView as? UIButton {
                button.tintColor = titleColor
            }
        }

        navigationItem.rightBarButtonItems?.forEach { item in
            item.tintColor = titleColor
            if let button = item.customView as? UIButton {
                button.tintColor = titleColor
            }
        }
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
    
    func setupNavigation(_ setting: NavigationSetting) {
        
        navigationItem.rightBarButtonItems = setting.rightButtons
        
        var leftItems: [UIBarButtonItem] = []
        
        // MARK: - Back Button
        if (navigationController?.viewControllers.count ?? 0) > 1 {
            
            let backButton = UIButton(type: .system)
            
            backButton.setImage(
                UIImage(systemName: "chevron.left"),
                for: .normal
            )
            
            backButton.tintColor = setting.titleColor
            navigationBackButton = backButton
            
            backButton.addTarget(
                self,
                action: #selector(onBackPress),
                for: .touchUpInside
            )
            
            let backItem = UIBarButtonItem(customView: backButton)
            leftItems.append(backItem)
        }
        
        // MARK: - Custom Left Items
        if let customLeftItems = setting.leftButtons {
            leftItems.append(contentsOf: customLeftItems)
        }
        
        navigationItem.leftBarButtonItems = leftItems
        
        // MARK: - Large Title Style
        if setting.useLargeTitleView {
            
            let container = makeLargeTitleView(title: setting.title)
            
            let titleItem = UIBarButtonItem(customView: container)
            
            leftItems.append(titleItem)
            title = nil
            
        } else {
            title = setting.title
        }
        navigationItem.leftBarButtonItems = leftItems
    }
    
    @objc func onBackPress() {
        navigationController?.popViewController(animated: true)
    }
    
    private func makeLargeTitleView(title: String?) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = navSetting.titleColor
        
        navigationTitleLabel = titleLabel
        
        return titleLabel
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        
        // Ignore UIControls
        if touch.view is UIControl {
            return false
        }
        
        // Ignore UITableViewCell
        if touch.view?.superview is UITableViewCell {
            return false
        }
        
        // Ignore UICollectionViewCell
        if touch.view?.superview is UICollectionViewCell {
            return false
        }
        
        return true
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}

typealias TIOScreenViewController<VM> = TIOViewController<VM, TIOLoadingTarget> where VM: TIOViewModel<TIOLoadingTarget>
