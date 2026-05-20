//
//  HomeViewController.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
import TIOPagingKit
import BaseMVVM

class HomeViewController<VM: HomeViewModel>: TIOCollectionViewController<VM> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    override func registerCells() -> [TIOCollectionViewCell.Type] {
        return [TIOCollectionViewCell.self]
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(type: TIOCollectionViewCell.self, for: indexPath)
        cell.backgroundColor = .orange
        return cell
    }
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
//        cell.backgroundColor = .orange
//        return cell
//    }
}

