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

class TIOViewController<VM: TIOViewModel>: BaseViewController<VM> {

    var cancelBag = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutIFSContentViewsIfNeeded()
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
