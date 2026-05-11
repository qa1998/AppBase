//
//  TIOListView.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
import TIOPagingKit

internal protocol TIOListView where Self: UIScrollView {
    func reloadData()
    func performBathUpdate(_ update: ((TIOListView) -> Void)?, completion: ((TIOListView) -> Void)?)
    func notiInsertItems(at indexPaths: [IndexPath])
    func notiDeleteItems(at indexPaths: [IndexPath])
}


