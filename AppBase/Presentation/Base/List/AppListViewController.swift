//
//  AppListViewController.swift
//  AppBase
//
//  Created by QuangAnh on 7/5/26.
//
import UIKit
import Combine

enum ListViewItemAmination {
    case fade
    case right
    case left
    case top
    case bottom
    case none
    case middle
    case automatic
    
    fileprivate func toRowAnimation() -> UITableView.RowAnimation {
        switch self {
        case .fade:
            return .fade
        case .right:
            return .right
        case .left:
            return .left
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .none:
            return .none
        case .middle:
            return .middle
        case .automatic:
            return .automatic
        }
    }
}

protocol IListView where Self: UIScrollView {
    func reloadData()
    func performBatchUpdates(_ updates: ((IListView) -> Void)?, completion: ((IListView) -> Void)?)
    func notifyInsertItems(at indexPaths: [IndexPath], with animation: ListViewItemAmination)
    func notifyInsertItems(at indexPaths: [IndexPath])
}

extension UITableView: IListView {
    
    func performBatchUpdates(_ updates: ((IListView) -> Void)?,
                             completion: ((IListView) -> Void)?) {
        self.performBatchUpdates { [weak self] in
            guard let this = self else { return }
            updates?(this)
        } completion: { [weak self] _ in
            guard let this = self else { return }
            completion?(this)
        }
    }
    
    func notifyInsertItems(at indexPaths: [IndexPath]) {
        self.notifyInsertItems(at: indexPaths, with: .none)
    }
    
    func notifyInsertItems(at indexPaths: [IndexPath],
                           with animation: ListViewItemAmination) {
        var total: Int = 0
        for section in 0..<self.numberOfSections {
            total += numberOfRows(inSection: section)
        }
        if #available(iOS 15.0, *) {
            if total == 0 {
                self.reconfigureRows(at: indexPaths)
            } else {
                self.insertRows(at: indexPaths, with: animation.toRowAnimation())
            }
        } else {
            self.insertRows(at: indexPaths, with: animation.toRowAnimation())
        }
    }
}

extension UICollectionView: IListView {
    func performBatchUpdates(_ updates: ((IListView) -> Void)?,
                             completion: ((IListView) -> Void)?) {
        self.performBatchUpdates { [weak self] in
            guard let this = self else { return }
            updates?(this)
        } completion: { [weak self] _ in
            guard let this = self else { return }
            completion?(this)
        }
    }
    func notifyInsertItems(at indexPaths: [IndexPath]) {
        self.notifyInsertItems(at: indexPaths, with: .none)
    }
    
    func notifyInsertItems(at indexPaths: [IndexPath],
                           with animation: ListViewItemAmination) {
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
}

