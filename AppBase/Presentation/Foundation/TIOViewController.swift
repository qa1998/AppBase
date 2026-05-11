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
    
    let cancelBag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let contentView = view.subviews.first(where: { $0 is IFSContentView }) {
//            contentView.removeFromSuperview()
//            view.addSubview(contentView)
//            contentView.snp.makeConstraints { make in
//                make.leading.equalTo(view.snp.leading)
//                make.trailing.equalTo(view.snp.trailing)
//                make.top.equalTo(view.snp.top)
//                make.bottom.equalTo(view.snp.bottom)
//            }
//        }
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func setupUI() {
        super.setupUI()
    }
    
    @objc func onBackPress() {
        navigationController?.popViewController(animated: true)
    }
}


