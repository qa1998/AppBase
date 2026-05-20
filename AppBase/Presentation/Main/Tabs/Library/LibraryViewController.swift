//
//  LibraryViewController.swift
//  AppBase
//

import UIKit
import BaseMVVM
import SnapKit
import Combine

class LibraryViewController<VM: LibraryViewModel>: TIOViewController<VM, LibraryLoadingEvent> {

    private let contentView = TIOContentView()

    private let titleLabel = TIOLabel()
    private let subtitleLabel = TIOLabel()

    private let loadTestButton = TIOButton(type: .system)
    private let loadTitleButton = TIOButton(type: .system)
    private let loadSubtitleButton = TIOButton(type: .system)

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            loadTestButton,
            loadTitleButton,
            loadSubtitleButton
        ])
        stack.axis = .vertical
        stack.spacing = Spacing.s12
        stack.distribution = .fillEqually
        return stack
    }()

    private let buttonRowHeight: CGFloat = 48

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshLocalization()
    }

    override func refreshLocalization() {
        title = L10n.Tab.library
        titleLabel.text = L10n.Library.title
        subtitleLabel.text = L10n.Library.Subtitle.hint
        loadTestButton.setTitle(L10n.Library.Button.testScreen, for: .normal)
        loadTitleButton.setTitle(L10n.Library.Button.shimmerTitle, for: .normal)
        loadSubtitleButton.setTitle(L10n.Library.Button.shimmerSubtitle, for: .normal)
    }

    override func setupUI() {
        super.setupUI()

        titleLabel.font = Font.bold(size: .text28)
        subtitleLabel.font = Font.default(size: .subtitle)

        [loadTestButton, loadTitleButton, loadSubtitleButton].forEach {
            $0.usesFilledPrimaryStyle = true
            $0.layer.cornerRadius = Radius.s12
        }

        view.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(buttonStack)

        // `TIOContentView` (IFSContentView) — pin full màn trong `layoutIFSContentViewsIfNeeded()`, không constraint ở đây.
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(Spacing.s24)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.s8)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
        }

        let stackHeight = buttonRowHeight * 3 + buttonStack.spacing * 2
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(Spacing.s32)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.height.equalTo(stackHeight)
        }
    }

    override func onBind() {
        super.onBind()

        viewModel.titleText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.titleLabel.text = $0 }
            .store(in: &cancelBag)

        viewModel.subtitleText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.subtitleLabel.text = $0 }
            .store(in: &cancelBag)

        loadTestButton.addTarget(self, action: #selector(didTapLoadTest), for: .touchUpInside)
        loadTitleButton.addTarget(self, action: #selector(didTapLoadTitle), for: .touchUpInside)
        loadSubtitleButton.addTarget(self, action: #selector(didTapLoadSubtitle), for: .touchUpInside)
    }

    override func shimmerViews(for event: LibraryLoadingEvent) -> [UIView] {
        switch event {
        case .screen:
            return [titleLabel, subtitleLabel, loadTestButton, loadTitleButton, loadSubtitleButton]
        case .title:
            return [titleLabel]
        case .subtitle:
            return [subtitleLabel]
        }
    }

    @objc private func didTapLoadTest() {
        viewModel.runFakeLoad(for: .screen)
    }

    @objc private func didTapLoadTitle() {
        viewModel.runFakeLoad(for: .title)
    }

    @objc private func didTapLoadSubtitle() {
        viewModel.runFakeLoad(for: .subtitle)
    }
}
