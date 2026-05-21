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

    private lazy var testEmptyBarButton = UIBarButtonItem(
        title: L10n.Home.Nav.testEmpty,
        style: .plain,
        target: self,
        action: #selector(didTapTestEmpty)
    )

    private lazy var testErrorBarButton = UIBarButtonItem(
        title: L10n.Home.Nav.testError,
        style: .plain,
        target: self,
        action: #selector(didTapTestError)
    )

    private lazy var testToastErrorBarButton = UIBarButtonItem(
        title: L10n.Home.Nav.testToastError,
        style: .plain,
        target: self,
        action: #selector(didTapTestToastError)
    )

    private lazy var testToastSuccessBarButton = UIBarButtonItem(
        title: L10n.Home.Nav.testToastSuccess,
        style: .plain,
        target: self,
        action: #selector(didTapTestToastSuccess)
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItems = [testToastSuccessBarButton, testToastErrorBarButton]
        navigationItem.rightBarButtonItems = [testErrorBarButton, testEmptyBarButton]
        refreshLocalization()
    }

    override func refreshLocalization() {
        title = L10n.Tab.home
        testEmptyBarButton.title = L10n.Home.Nav.testEmpty
        testErrorBarButton.title = L10n.Home.Nav.testError
        testToastErrorBarButton.title = L10n.Home.Nav.testToastError
        testToastSuccessBarButton.title = L10n.Home.Nav.testToastSuccess
    }

    @objc private func didTapTestEmpty() {
        viewModel.showTestEmptyState()
    }

    @objc private func didTapTestError() {
        viewModel.showTestErrorState()
    }

    @objc private func didTapTestToastError() {
        viewModel.showTestToastError()
    }

    @objc private func didTapTestToastSuccess() {
        viewModel.showTestToastSuccess()
    }

    override func registerCellClasses() -> [TIOTableViewCell.Type] {
        [HomeBankCell.self]
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = dequeueListCell(HomeBankCell.self, from: tableView, for: indexPath)
        if let bank = viewModel.item(at: indexPath) as? Bank {
            cell.configure(with: bank)
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
