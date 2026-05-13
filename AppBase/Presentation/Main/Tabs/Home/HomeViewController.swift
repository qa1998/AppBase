//
//  HomeViewController.swift
//  AppBase
//

import BaseMVVM
import SnapKit
import UIKit

final class HomeViewController: TIOTableViewController<HomeViewModel> {

    var onTapCreateScript: (() -> Void)?
    var onSelectScript: ((TeleprompterScript) -> Void)?

    override func setupUI() {
        super.setupUI()
        view.backgroundColor = .systemBackground
        title = "Home"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(onTapSettings)
        )
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableHeaderView = makeHeaderView()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 12))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reload()
    }

    override func listEmptyTitleString() -> String {
        "Chưa có script"
    }

    override func listEmptyDescriptionString() -> String? {
        "Nhấn \"Tạo script mới\" phía trên để tạo."
    }

    override func listEmptyImage() -> UIImage? {
        UIImage(systemName: "doc.text")
    }

    private func makeHeaderView() -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 120))
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        let createButton = UIButton(type: .system)
        createButton.setTitle("  Tạo script mới", for: .normal)
        createButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        createButton.tintColor = .white
        createButton.backgroundColor = .black
        createButton.layer.cornerRadius = 12
        createButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        createButton.addTarget(self, action: #selector(onTapCreate), for: .touchUpInside)
        createButton.heightAnchor.constraint(equalToConstant: 52).isActive = true

        let sectionTitle = UILabel()
        sectionTitle.text = "Script của tôi"
        sectionTitle.font = .systemFont(ofSize: 20, weight: .bold)

        stack.addArrangedSubview(createButton)
        stack.addArrangedSubview(sectionTitle)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        return container
    }

    @objc private func onTapCreate() {
        onTapCreateScript?()
    }

    @objc private func onTapSettings() {
        tabBarController?.selectedIndex = 3
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
        config.textProperties.color = .label
        config.secondaryTextProperties.color = .secondaryLabel
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
