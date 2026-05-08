//
//  TIOViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import BaseMVVM
import Combine
import UIKit

class TIOViewController<VM: TIOViewModel>: BaseViewController<VM> {
    
    let cancelBag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}


