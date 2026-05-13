//
//  SciptViewController.swift
//  AppBase
//

import BaseMVVM
import SnapKit
import UIKit

final class SciptViewController: TIOTableViewController<ScriptViewModel>, UISearchResultsUpdating {

    var onSelectScript: ((TeleprompterScript) -> Void)?

    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Tìm kiếm"
        return sc
    }()

    override func setupUI() {
        super.setupUI()
        view.backgroundColor = .systemBackground
        title = "Scripts"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reload()
    }

    override func listEmptyTitleString() -> String {
        if viewModel.hasNoSavedScripts {
            return "Không có script"
        }
        if viewModel.isShowingEmptySearch {
            return "Không tìm thấy"
        }
        return super.listEmptyTitleString()
    }

    override func listEmptyDescriptionString() -> String? {
        if viewModel.hasNoSavedScripts {
            return "Tạo script mới từ tab Home."
        }
        if viewModel.isShowingEmptySearch {
            return "Thử từ khóa khác."
        }
        return nil
    }

    override func listEmptyImage() -> UIImage? {
        UIImage(systemName: "doc.text.magnifyingglass")
    }

    func updateSearchResults(for searchController: UISearchController) {
        viewModel.setSearch(searchController.searchBar.text ?? "")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        var config = cell.defaultContentConfiguration()
        guard let script = viewModel.script(at: indexPath.row) else {
            return cell
        }
        config.image = UIImage(systemName: "doc.text.fill")
        config.text = script.title.isEmpty ? "Không tiêu đề" : script.title
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "vi_VN")
        config.secondaryText = "\(formatter.string(from: script.updatedAt)) · \(script.estimatedReadMinutes) phút"
        cell.accessoryType = .disclosureIndicator
        cell.contentConfiguration = config
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let script = viewModel.script(at: indexPath.row) else { return }
        onSelectScript?(script)
    }
}
