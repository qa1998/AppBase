//
//  ScriptEditorViewController.swift
//  AppBase
//

import BaseMVVM
import SnapKit
import UIKit

final class ScriptEditorViewController: TIOViewController<ScriptEditorViewModel> {

    var onDidSave: ((TeleprompterScript) -> Void)?

    private let titleField = UITextField()
    private let bodyTextView = UITextView()

    init(repository: ScriptRepository, script: TeleprompterScript?) {
        super.init(nibName: nil, bundle: nil)
        invoke(viewModel: ScriptEditorViewModel(repository: repository, script: script))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupUI() {
        super.setupUI()
        view.backgroundColor = .systemBackground
        title = viewModel.isEditing ? "Sửa script" : "Script mới"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Hủy",
            style: .plain,
            target: self,
            action: #selector(onCancel)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Lưu",
            style: .done,
            target: self,
            action: #selector(onSave)
        )

        titleField.placeholder = "Tiêu đề script"
        titleField.borderStyle = .roundedRect
        titleField.text = viewModel.editingScript?.title
        titleField.font = .systemFont(ofSize: 16, weight: .medium)

        bodyTextView.font = .systemFont(ofSize: 16)
        bodyTextView.text = viewModel.editingScript?.content
        bodyTextView.textColor = .label
        bodyTextView.backgroundColor = .secondarySystemBackground
        bodyTextView.layer.cornerRadius = 8
        bodyTextView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)

        let placeholder = UILabel()
        placeholder.text = "Nhập hoặc dán nội dung của bạn..."
        placeholder.textColor = .placeholderText
        placeholder.font = .systemFont(ofSize: 16)
        placeholder.tag = 9001
        bodyTextView.addSubview(placeholder)
        placeholder.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(13)
        }
        updatePlaceholderVisibility()
        bodyTextView.delegate = self

        view.addSubview(titleField)
        view.addSubview(bodyTextView)
        titleField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        bodyTextView.snp.makeConstraints { make in
            make.top.equalTo(titleField.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }

    private func updatePlaceholderVisibility() {
        bodyTextView.viewWithTag(9001)?.isHidden = !bodyTextView.text.isEmpty
    }

    @objc private func onCancel() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onSave() {
        let saved = viewModel.save(title: titleField.text ?? "", content: bodyTextView.text ?? "")
        onDidSave?(saved)
        navigationController?.popViewController(animated: true)
    }
}

extension ScriptEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
}
