//
//  ScriptsViewController.swift
//  AppBase
//

import UIKit
import BaseMVVM

class ScriptsViewController<VM: ScriptsViewModel>: TIOScreenViewController<VM> {

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshLocalization()
    }

    override func refreshLocalization() {
        title = L10n.Tab.scripts
    }
}
