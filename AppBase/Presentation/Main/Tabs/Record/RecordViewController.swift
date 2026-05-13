//
//  RecordViewController.swift
//  AppBase
//
//  Created by QuangAnh on 12/5/26.
//

import BaseMVVM
import SnapKit
import UIKit

final class RecordViewController: TIOTableViewController<RecordViewModel> {

    var onSelectScript: ((TeleprompterScript) -> Void)?

    override func setupUI() {

        super.setupUI()

        view.backgroundColor = .systemBackground
        title = "Record"
        tableView.separatorInset =
            UIEdgeInsets(
                top: 0,
                left: 16,
                bottom: 0,
                right: 16
            )
    }

    override func viewWillAppear(
        _ animated: Bool
    ) {

        super.viewWillAppear(
            animated
        )

        viewModel.reload()
    }

    override func listEmptyTitleString() -> String {
        "Chưa có script"
    }

    override func listEmptyDescriptionString() -> String? {
        "Tạo script trước, sau đó vào tab Record để thu âm theo script."
    }

    override func listEmptyImage() -> UIImage? {
        UIImage(
            systemName: "mic.badge.plus"
        )
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "cell"
            )
            ?? UITableViewCell(
                style: .subtitle,
                reuseIdentifier: "cell"
            )

        var config =
            cell.defaultContentConfiguration()

        guard let script =
            viewModel.script(
                at: indexPath.row
            )
        else {
            return cell
        }

        let count =
            viewModel.recordingCount(
                scriptId: script.id
            )

        config.image =
            UIImage(
                systemName: "video.fill"
            )

        config.text =
            script.title.isEmpty
            ? "Không tiêu đề"
            : script.title

        config.secondaryText =
            "\(script.estimatedReadMinutes) phút đọc · \(count) video"

        cell.accessoryType = .disclosureIndicator
        cell.contentConfiguration = config

        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        guard let script =
            viewModel.script(
                at: indexPath.row
            )
        else {
            return
        }

        onSelectScript?(
            script
        )
    }
}
