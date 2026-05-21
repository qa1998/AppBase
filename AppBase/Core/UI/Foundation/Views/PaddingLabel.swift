//
//  PaddingLabel.swift
//  AppBase
//
//  Created by QuangAnh on 21/5/26.
//

import UIKit

class PaddingLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 4,
                                  left: 4,
                                  bottom: 4,
                                  right: 4)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }
}
