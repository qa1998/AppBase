//
//  LibraryViewController.swift
//  AppBase
//

import UIKit
import BaseMVVM
import SnapKit
import Combine

class LibraryViewController<VM: LibraryViewModel>: TIOViewController<VM, LibraryLoadingEvent> {

    private let contentView = TIOView()

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
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = L10n.Tab.library
    }

    override func setupUI() {
        super.setupUI()

        titleLabel.font = Font.bold(size: .text28)
        titleLabel.text = "Library"
        titleLabel.textColor = .label

        subtitleLabel.font = Font.default(size: .subtitle)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.text = "Tap a button to test shimmer"

        loadTestButton.setTitle("Test loading (screen)", for: .normal)
        loadTitleButton.setTitle("Shimmer title only", for: .normal)
        loadSubtitleButton.setTitle("Shimmer subtitle only", for: .normal)

        [loadTestButton, loadTitleButton, loadSubtitleButton].forEach {
            $0.backgroundColor = .systemBlue
            $0.setTitleColor(.white, for: .normal)
            $0.layer.cornerRadius = 12
            $0.snp.makeConstraints { make in
                make.height.equalTo(48)
            }
        }

        view.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(buttonStack)

        contentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }

        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            make.leading.trailing.bottom.equalToSuperview()
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
