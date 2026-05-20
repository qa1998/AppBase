//
//  RecordViewController.swift
//  AppBase
//

import UIKit
import BaseMVVM
import SnapKit

class RecordViewController<VM: RecordViewModel>: TIOScreenViewController<VM> {

    private let actionButtons: [TIOButton] = (1...5).map { _ in TIOButton(type: .system) }

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: actionButtons)
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
        title = L10n.Tab.record
        for (index, button) in actionButtons.enumerated() {
            button.setTitle("Action \(index + 1)", for: .normal)
        }
    }

    override func setupUI() {
        super.setupUI()

        actionButtons.forEach {
            $0.usesFilledPrimaryStyle = true
            $0.layer.cornerRadius = Radius.s12
        }

        view.addSubview(buttonStack)

        let stackHeight = buttonRowHeight * CGFloat(actionButtons.count)
            + buttonStack.spacing * CGFloat(actionButtons.count - 1)

        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Spacing.s24)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.height.equalTo(stackHeight)
        }
    }

    override func onBind() {
        super.onBind()

        for (index, button) in actionButtons.enumerated() {
            button.tag = index + 1
            button.addTarget(self, action: #selector(didTapActionButton(_:)), for: .touchUpInside)
        }
    }

    @objc private func didTapActionButton(_ sender: TIOButton) {
        viewModel.pushTestScreen(step: sender.tag)
    }
}
