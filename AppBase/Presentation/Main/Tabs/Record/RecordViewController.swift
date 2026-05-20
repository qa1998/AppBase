//
//  RecordViewController.swift
//  AppBase
//

import UIKit
import BaseMVVM

class RecordViewController<VM: RecordViewModel>: TIOScreenViewController<VM> {

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshLocalization()
    }

    override func refreshLocalization() {
        title = L10n.Tab.record
    }
}
