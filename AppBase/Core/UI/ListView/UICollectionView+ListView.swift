//
//  UICollectionView.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
extension UICollectionView: TIOListView {
    func performBathUpdate(_ update: ((TIOListView) -> Void)?, completion: ((TIOListView) -> Void)?) {
        self.performBatchUpdates { [weak self] in
            guard let this = self else { return }
            update?(this)
        } completion: { [weak self] _ in
            guard let this = self else { return }
            completion?(this)
        }
    }
    
    func notiInsertItems(at indexPaths: [IndexPath]) {
        var total: Int = 0
        for section in 0..<self.numberOfSections {
            total += numberOfItems(inSection: section)
        }
        if #available(iOS 15.0, *) {
            if total == 0 {
                self.reconfigureItems(at: indexPaths)
            } else {
                self.insertItems(at: indexPaths)
            }
        } else {
            self.insertItems(at: indexPaths)
        }
    }
    func notiDeleteItems(at indexPaths: [IndexPath]) {
        self.deleteItems(at: indexPaths)
    }
}
