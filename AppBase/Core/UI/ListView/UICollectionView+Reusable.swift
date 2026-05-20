//
//  UICollectionView+Reusable.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit

extension UICollectionView {
    func registerClass(cell: TIOCollectionViewCell.Type) {
        register(cell, forCellWithReuseIdentifier: cell.reuseIdentifier)
    }

    func registerNib(cell: TIOCollectionViewCell.Type) {
        register(UINib(nibName: cell.reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: cell.reuseIdentifier)
    }

    func registerCells(_ cellClasses: [TIOCollectionViewCell.Type], useNib: Bool = false) {
        for cellClass in cellClasses {
            if useNib {
                registerNib(cell: cellClass)
            } else {
                registerClass(cell: cellClass)
            }
        }
    }
    
    func dequeueReusableCell<T: TIOCollectionViewCell>(type: T.Type,
                                                       withIdentifier identifier: String? = nil,
                                                       for indexPath: IndexPath) -> T {
        let reuseId = identifier ?? type.reuseIdentifier
        guard let cell = dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? T else {
            fatalError("\(String(describing: self)) could not dequeue cell with identifier: \(reuseId)")
        }
        return cell
    }
}

