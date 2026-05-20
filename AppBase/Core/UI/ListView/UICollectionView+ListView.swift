//
//  UICollectionView.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
extension UICollectionView: TIOListView {
    func performBatchUpdates(_ update: ((TIOListView) -> Void)?, completion: ((TIOListView) -> Void)?) {
        self.performBatchUpdates { [weak self] in
            guard let this = self else { return }
            update?(this)
        } completion: { [weak self] _ in
            guard let this = self else { return }
            completion?(this)
        }
    }
    
    func notifyInsertItems(at indexPaths: [IndexPath]) {
        if numberOfSections == 0 || indexPaths.isEmpty {
            reloadData()
            return
        }
        insertItems(at: indexPaths)
    }
    func notiDeleteItems(at indexPaths: [IndexPath]) {
        self.deleteItems(at: indexPaths)
    }
}
