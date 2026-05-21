//
//  ScriptsViewController.swift
//  AppBase
//

import UIKit
import BaseMVVM
import SnapKit
import Combine

final class ScriptsViewController<VM: ScriptsViewModel>: TIOScreenViewController<VM> {

    private let contentView = TIOContentView()
    private let hintLabel = TIOLabel()
    private let statusLabel = TIOLabel()

    private let buttonRowHeight: CGFloat = 48

    private lazy var actionButtons: [TIOButton] = [
        makeActionButton(#selector(didTapLoadBanner)),
        makeActionButton(#selector(didTapShowBanner)),
        makeActionButton(#selector(didTapHideBanner)),
        makeActionButton(#selector(didTapLoadInterstitial)),
        makeActionButton(#selector(didTapShowInterstitial)),
        makeActionButton(#selector(didTapLoadRewarded)),
        makeActionButton(#selector(didTapShowRewarded)),
        makeActionButton(#selector(didTapLoadAppOpen)),
        makeActionButton(#selector(didTapShowAppOpen))
    ]

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: actionButtons)
        stack.axis = .vertical
        stack.spacing = Spacing.s12
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        return scroll
    }()

    private let scrollContentView = TIOView()

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshLocalization()
    }

    override func refreshLocalization() {
        title = L10n.Tab.scripts
        hintLabel.text = L10n.Scripts.Ads.hint
        let titles = [
            L10n.Scripts.Ads.loadBanner,
            L10n.Scripts.Ads.showBanner,
            L10n.Scripts.Ads.hideBanner,
            L10n.Scripts.Ads.loadInterstitial,
            L10n.Scripts.Ads.showInterstitial,
            L10n.Scripts.Ads.loadRewarded,
            L10n.Scripts.Ads.showRewarded,
            L10n.Scripts.Ads.loadAppOpen,
            L10n.Scripts.Ads.showAppOpen
        ]
        zip(actionButtons, titles).forEach { button, title in
            button.setTitle(title, for: .normal)
        }
    }

    override func setupUI() {
        super.setupUI()

        hintLabel.font = Font.default(size: .subtitle)
        statusLabel.font = Font.default(size: .text15)
        statusLabel.numberOfLines = 0

        actionButtons.forEach {
            $0.usesFilledPrimaryStyle = true
            $0.layer.cornerRadius = Radius.s12
        }

        view.addSubview(contentView)
        contentView.addSubview(hintLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(buttonStack)

        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(Spacing.s16)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
        }

        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(Spacing.s12)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(Spacing.s16)
            make.leading.trailing.bottom.equalToSuperview()
        }

        scrollContentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        let stackHeight = buttonRowHeight * CGFloat(actionButtons.count)
            + buttonStack.spacing * CGFloat(actionButtons.count - 1)
        buttonStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.bottom.equalToSuperview().inset(Spacing.s24)
            make.height.equalTo(stackHeight)
        }
    }

    override func onBind() {
        super.onBind()
        viewModel.statusText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.statusLabel.text = $0 }
            .store(in: &cancelBag)
    }

    // MARK: - Actions

    @objc private func didTapLoadBanner() { viewModel.loadBanner() }
    @objc private func didTapShowBanner() { viewModel.showBanner(from: self) }
    @objc private func didTapHideBanner() { viewModel.hideBanner() }
    @objc private func didTapLoadInterstitial() { viewModel.loadInterstitial() }
    @objc private func didTapShowInterstitial() { viewModel.showInterstitial(from: self) }
    @objc private func didTapLoadRewarded() { viewModel.loadRewarded() }
    @objc private func didTapShowRewarded() { viewModel.showRewarded(from: self) }
    @objc private func didTapLoadAppOpen() { viewModel.loadAppOpen() }
    @objc private func didTapShowAppOpen() { viewModel.showAppOpen(from: self) }

    private func makeActionButton(_ action: Selector) -> TIOButton {
        let button = TIOButton(type: .system)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
