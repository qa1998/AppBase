//
//  UITableView.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit

extension UITableView: TIOListView {
    func performBatchUpdates(_ update: ((TIOListView) -> Void)?, completion: ((TIOListView) -> Void)?) {
        self.performBatchUpdates { [weak self] in
            guard let this = self else { return }
            update?(this)
        } completion: { [weak self] _ in
            guard let this = self else {return}
            completion?(this)
        }
        
        
    }
    func notifyInsertItems(at indexPaths: [IndexPath]) {
        if numberOfSections == 0 || indexPaths.isEmpty {
            reloadData()
            return
        }
        insertRows(at: indexPaths, with: .none)
    }
    
    func notiDeleteItems(at indexPaths: [IndexPath]) {
        self.beginUpdates()
        self.deleteRows(at: indexPaths, with: .fade)
        self.endUpdates()
    }
}
