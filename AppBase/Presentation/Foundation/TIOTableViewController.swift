//
//  TIOTableViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import TIOPagingKit
import UIKit
import BaseMVVM

class TIOTableViewController<VM: TIOListViewModel>: TIOListViewController<VM>,
                                                    UITableViewDelegate,
                                                    UITableViewDataSource {
    
    lazy var tableView: TIOPagingTableView = {
        let tableView = TIOPagingTableView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func createListView() -> any TIOListView {
        return tableView
    }
    func registerNibs() -> [TIOTableViewCell.Type] {
        return []
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return viewModel.numOfItemsInSection(section)
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("func cellForRowAt require override at instance")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectItem(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

