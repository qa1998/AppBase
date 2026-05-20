//
//  LibraryViewController.swift
//  AppBase
//

import UIKit
import BaseMVVM

class LibraryViewController<VM: LibraryViewModel>: TIOViewController<VM> {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = L10n.Tab.library
    }
}
