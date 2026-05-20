//
//  MaintanceViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
import BaseMVVM
import SnapKit

class MaintanceViewModel: TIOViewModel<TIOLoadingTarget> {}

class MaintanceViewController: TIOScreenViewController<MaintanceViewModel> {

    private let messageLabel = TIOLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshLocalization()
    }

    override func setupUI() {
        super.setupUI()
        messageLabel.textAlignment = .center
        view.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Spacing.s24)
        }
    }

    override func refreshLocalization() {
        title = L10n.Maintain.title
        messageLabel.text = L10n.Maintain.message
    }
}
