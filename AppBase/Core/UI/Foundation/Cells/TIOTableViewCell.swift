//
//  TIOTableViewCell.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//


import UIKit
class TIOTableViewCell: UITableViewCell {
    var isEnableHighlight: Bool {
        return true
    }
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: String(describing: self), bundle: .main)
    }
    
    var selectedColor: UIColor {
        
        return .gray
    }
    
    class func cellHeight(for data: Any?) -> CGFloat {
        return 56.0
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        guard isEnableHighlight else {
            return
        }
        super.setSelected(selected, animated: animated)
        if isEditing && selected {
            let highlightView = UIView(frame: contentView.frame)
            highlightView.backgroundColor = .clear
            selectedBackgroundView = highlightView
        }
    }
    
    private func commonInit() {
        backgroundColor = ThemeManager.shared.colors.backgroundPrimary
//        tintColor = UIColor(r: 0, g: 136, b: 255)
        separatorInset = .zero

        let selectedView = UIView(frame: .zero)
        selectedView.backgroundColor = selectedColor
        self.selectedBackgroundView = selectedView
    }
    
    func updateDisplay(with data: Any?) {
        
    }
}
