//
//  TIOCollectionViewCell.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
class TIOCollectionViewCell: UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        self.setupLayout()
    }
    
    func setupLayout(){
        
    }
    func updateDisplay(data: Any?){
        
    }
    
    class func cellSize(data: Any?) -> CGSize {
        return .zero
    }
}
