//
//  RecordViewController.swift
//  AppBase
//

import UIKit
import BaseMVVM

class RecordViewController<VM: RecordViewModel>: TIOViewController<VM> {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = L10n.Tab.record
    }
}
