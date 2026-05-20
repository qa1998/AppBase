//
//  RecordTestViewController.swift
//  AppBase
//

import UIKit
import BaseMVVM
import Combine
import SnapKit

enum RecordTestNavigation {
    case pop
    case push(step: Int)
}

final class RecordTestViewModel: TIOViewModel<TIOLoadingTarget> {
    let step: Int
    let navigationAction = PassthroughSubject<RecordTestNavigation, Never>()

    init(step: Int) {
        self.step = step
        super.init()
    }

    func requestPop() {
        navigationAction.send(.pop)
    }

    func requestPush(step: Int) {
        navigationAction.send(.push(step: step))
    }
}

/// Màn test dùng chung khi push từ Record (phân biệt bằng `step` 1…5).
final class RecordTestViewController: TIOScreenViewController<RecordTestViewModel> {

    private let messageLabel = TIOLabel()
    private let popButton = TIOButton(type: .system)
    private let pushAgainButton = TIOButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshLocalization()
    }

    override func setupUI() {
        super.setupUI()

        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = Font.bold(size: .text22)

        [popButton, pushAgainButton].forEach {
            $0.usesFilledPrimaryStyle = true
            $0.layer.cornerRadius = Radius.s12
        }

        view.addSubview(messageLabel)
        view.addSubview(popButton)
        view.addSubview(pushAgainButton)

        messageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-Spacing.s40)
            make.leading.trailing.equalToSuperview().inset(Spacing.s24)
        }

        popButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(Spacing.s32)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.height.equalTo(48)
        }

        pushAgainButton.snp.makeConstraints { make in
            make.top.equalTo(popButton.snp.bottom).offset(Spacing.s12)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.height.equalTo(48)
        }
    }

    override func onBind() {
        super.onBind()
        popButton.addTarget(self, action: #selector(didTapPop), for: .touchUpInside)
        pushAgainButton.addTarget(self, action: #selector(didTapPushAgain), for: .touchUpInside)
    }

    override func refreshLocalization() {
        title = "Test \(viewModel.step)"
        messageLabel.text = "Record test screen — action \(viewModel.step)"
        popButton.setTitle("Pop (Coordinator)", for: .normal)
        pushAgainButton.setTitle("Push again (Coordinator)", for: .normal)
    }

    @objc private func didTapPop() {
        viewModel.requestPop()
    }

    @objc private func didTapPushAgain() {
        viewModel.requestPush(step: viewModel.step)
    }
}
