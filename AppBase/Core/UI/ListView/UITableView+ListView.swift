//
//  UITableView.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit

extension UITableView: TIOListView {
    func performBathUpdate(_ update: ((TIOListView) -> Void)?, completion: ((TIOListView) -> Void)?) {
        self.performBatchUpdates { [weak self] in
            guard let this = self else { return }
            update?(this)
        } completion: { [weak self] _ in
            guard let this = self else {return}
            completion?(this)
        }
        
        
    }
    func notiInsertItems(at indexPaths: [IndexPath]) {
        var total: Int = 0
        for section in 0..<self.numberOfSections {
            total += numberOfRows(inSection: section)
        }
        if #available(iOS 15.0, *) {
            if total == 0 {
                self.reconfigureRows(at: indexPaths)
            } else {
                self.insertRows(at: indexPaths, with: .none)
            }
        } else {
            self.insertRows(at: indexPaths, with: .none)
        }
    }
    
    func notiDeleteItems(at indexPaths: [IndexPath]) {
        self.beginUpdates()
        self.deleteRows(at: indexPaths, with: .fade)
        self.endUpdates()
    }
}
