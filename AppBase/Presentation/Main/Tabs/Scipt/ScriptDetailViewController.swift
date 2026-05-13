//
//  ScriptDetailViewController.swift
//  AppBase
//

import BaseMVVM
import SnapKit
import UIKit

final class ScriptDetailViewController: TIOViewController<ScriptDetailViewModel> {

    var onTapEdit: ((TeleprompterScript) -> Void)?
    var onTapPlay: ((TeleprompterScript) -> Void)?
    var onDidDelete: (() -> Void)?

    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private let bodyLabel = UILabel()
    private let toolbar = UIToolbar()

    init(repository: ScriptRepository, script: TeleprompterScript) {
        super.init(nibName: nil, bundle: nil)
        invoke(viewModel: ScriptDetailViewModel(repository: repository, script: script))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupUI() {
        super.setupUI()
        view.backgroundColor = .systemBackground
        title = "Chi tiết script"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Sửa",
            style: .plain,
            target: self,
            action: #selector(onEdit)
        )

        let scroll = UIScrollView()
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        view.addSubview(scroll)
        view.addSubview(toolbar)
        scroll.addSubview(stack)

        toolbar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(49)
        }

        scroll.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(toolbar.snp.top)
        }
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.width.equalTo(scroll.snp.width).offset(-32)
        }

        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.numberOfLines = 0

        metaLabel.font = .systemFont(ofSize: 14, weight: .regular)
        metaLabel.textColor = .secondaryLabel

        bodyLabel.font = .systemFont(ofSize: 17, weight: .regular)
        bodyLabel.numberOfLines = 0
        bodyLabel.textColor = .label

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(metaLabel)
        stack.addArrangedSubview(bodyLabel)

        let play = UIBarButtonItem(image: UIImage(systemName: "play.fill"), style: .plain, target: self, action: #selector(onPlay))
        let share = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(onShare))
        let delete = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(onDelete))
        delete.tintColor = .systemRed
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [play, flex, share, flex, delete]

        applyScript()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshFromStore()
        applyScript()
    }

    private func applyScript() {
        let s = viewModel.script
        titleLabel.text = s.title.isEmpty ? "Không tiêu đề" : s.title
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "vi_VN")
        metaLabel.text = "\(formatter.string(from: s.updatedAt)) · \(s.estimatedReadMinutes) phút đọc"
        bodyLabel.text = s.content.isEmpty ? "(Chưa có nội dung)" : s.content
    }

    @objc private func onEdit() {
        onTapEdit?(viewModel.script)
    }

    @objc private func onPlay() {
        onTapPlay?(viewModel.script)
    }

    @objc private func onShare() {
        let text = "\(viewModel.script.title)\n\n\(viewModel.script.content)"
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(vc, animated: true)
    }

    @objc private func onDelete() {
        let alert = UIAlertController(
            title: "Xóa script?",
            message: "Hành động này không thể hoàn tác.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Xóa", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteScript()
            self?.onDidDelete?()
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
