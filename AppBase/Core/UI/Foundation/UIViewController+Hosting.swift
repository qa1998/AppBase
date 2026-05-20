//
//  UIViewController+Hosting.swift
//  AppBase
//

import SnapKit
import SwiftUI
import UIKit

extension UIViewController {

    func embedHostingController<Content: View>(
        _ hostingController: UIHostingController<Content>,
        in containerView: UIView? = nil
    ) {
        let target = containerView ?? view
        addChild(hostingController)
        target?.addSubview(hostingController.view)
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        hostingController.didMove(toParent: self)
    }
}
