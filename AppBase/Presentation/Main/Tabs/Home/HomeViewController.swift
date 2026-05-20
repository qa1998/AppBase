//
//  HomeViewController.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
import TIOPagingKit
import BaseMVVM

class HomeViewController<VM: HomeViewModel>: TIOTableViewController<VM> {

    private let listRowHeight: CGFloat = 72

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshLocalization()
    }

    override func refreshLocalization() {
        title = L10n.Tab.home
    }

    override func registerCellClasses() -> [TIOTableViewCell.Type] {
        [TIOTableViewCell.self]
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            type: TIOTableViewCell.self,
            for: indexPath
        )
        if viewModel.isListCellLoading {
            cell.applyListShimmer(true)
        } else {
            cell.applyListShimmer(false)
            cell.backgroundColor = .orange
        }
        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        listRowHeight
    }
}
