//
//  HomeViewController.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
import TIOPagingKit
class HomeViewController<VM: HomeViewModel>: TIOTableViewController<VM> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .orange
        return cell
    }
}

