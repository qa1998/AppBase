//
//  UITableView+Reusable.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//
import UIKit
extension UITableView {
    func registerNib(for cellClass: TIOTableViewCell.Type) {
        registerNib(for: cellClass, reuseId: cellClass.reuseIdentifier)
    }
    
    func registerNib(for cellClass: TIOTableViewCell.Type, reuseId: String) {
        register(cellClass.nib, forCellReuseIdentifier: reuseId)
    }
    
    func registerClass(for cellClass: TIOTableViewCell.Type) {
        registerClass(for: cellClass, reuseId: cellClass.reuseIdentifier)
    }
    
    func registerClass(for cellClass: TIOTableViewCell.Type, reuseId: String) {
        register(cellClass, forCellReuseIdentifier: reuseId)
    }
    
    func registerNibs<T: TIOTableViewCell>(for cellClasses: [T.Type]) {
        for cellClass in cellClasses {
            registerNib(for: cellClass)
        }
    }
    
    func dequeueReusableCell<T: TIOTableViewCell>(type: T.Type,
                                                  withIdentifier identifier: String? = nil,
                                                  for indexPath: IndexPath) -> T {
        let reuseId = identifier ?? type.reuseIdentifier
        guard let cell = self.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as? T else {
            fatalError("\(String(describing: self)) could not dequeue cell with identifier: \(reuseId)")
        }
        return cell
    }
    //
    func insertRows(_ rows: [Int], inSection section: Int, animated: Bool = true) {
        insertRows(at: rows.map { IndexPath(row: $0, section: section) }, with: animated ? .automatic : .none)
    }
    
    func deleteRow(_ row: Int, inSection section: Int, animated: Bool = true) {
        deleteRows(at: [IndexPath(row: row, section: section)], with: animated ? .automatic : .none)
    }
    
    func deleteRows(_ rows: [Int], inSection section: Int, animated: Bool = true) {
        deleteRows(at: rows.map { IndexPath(row: $0, section: section) }, with: animated ? .automatic : .none)
    }
    
    func reloadRow(_ row: Int, inSection section: Int, animated: Bool = true) {
        reloadRows(at: [IndexPath(row: row, section: section)], with: animated ? .automatic : .none)
    }
    
    func reloadRows(_ rows: [Int], inSection section: Int, animated: Bool = true) {
        reloadRows(at: rows.map { IndexPath(row: $0, section: section) }, with: animated ? .automatic : .none)
    }
    
    func insertSection(_ section: Int, animated: Bool = true) {
        insertSections(IndexSet(integer: section), with: animated ? .automatic : .none)
    }
    
    func reloadSection(_ section: Int, animated: Bool = true) {
        reloadSections(IndexSet(integer: section), with: animated ? .automatic : .none)
    }
    
    func batchUpdates(_ updates: (UITableView) -> Void, completion: ((Bool) -> Void)? = nil) {
        if #available(iOS 11.0, *) {
            performBatchUpdates({
                updates(self)
            }, completion: completion)
        } else {
            beginUpdates()
            updates(self)
            endUpdates()
            completion?(true)
        }
    }
    
    func alertRow(at indexPath: IndexPath) {
        scrollToRow(at: indexPath, at: .middle, animated: true)
        selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func alertSection(_ section: Int) {
        let numberOfRows = self.numberOfRows(inSection: section)
        let indexPaths = (0..<numberOfRows).map({ IndexPath(row: $0, section: section) })
        
        guard let firstIndexPath = indexPaths.first else {
            return
        }
        
        scrollToRow(at: firstIndexPath, at: .middle, animated: true)
        
        for indexPath in indexPaths {
            selectRow(at: indexPath, animated: true, scrollPosition: .middle)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}
