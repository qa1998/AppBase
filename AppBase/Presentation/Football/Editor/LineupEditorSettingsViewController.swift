//
//  LineupEditorSettingsViewController.swift
//  AppBase
//

import SnapKit
import UIKit

/// Bottom sheet — edit tactical / lineup display name for the current editor session.
final class LineupEditorSettingsViewController: UIViewController {

    var onSave: ((String) -> Void)?

    private let initialTitle: String
    private var draftTitle: String

    private let headerBar = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let nameLabel = UILabel()
    private let nameField = UITextField()
    private let saveButton = UIButton(type: .system)

    init(title: String) {
        initialTitle = title
        draftTitle = title
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = FootballPalette.background
        setupSheet()
        buildUI()
        layoutViews()
        syncUI()
    }

    private func setupSheet() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = Radius.s20
        }
    }

    private func buildUI() {
        titleLabel.text = L10n.Football.Editor.Settings.title
        titleLabel.font = FootballPalette.title(18)
        titleLabel.textColor = FootballPalette.textPrimary

        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = FootballPalette.textPrimary
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        headerBar.addSubview(titleLabel)
        headerBar.addSubview(closeButton)

        nameLabel.text = L10n.Football.Editor.Settings.nameLabel
        nameLabel.font = FootballPalette.title(15)
        nameLabel.textColor = FootballPalette.textSecondary

        nameField.font = FootballPalette.title(16)
        nameField.textColor = FootballPalette.textPrimary
        nameField.backgroundColor = FootballPalette.surface
        nameField.layer.cornerRadius = Radius.s12
        nameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Spacing.s12, height: 1))
        nameField.leftViewMode = .always
        nameField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: Spacing.s12, height: 1))
        nameField.rightViewMode = .always
        nameField.autocapitalizationType = .words
        nameField.returnKeyType = .done
        nameField.clearButtonMode = .whileEditing
        nameField.placeholder = L10n.Football.Editor.Settings.namePlaceholder
        nameField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        nameField.delegate = self

        saveButton.setTitle(L10n.Football.Editor.Settings.save, for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = FootballPalette.title(16)
        saveButton.backgroundColor = FootballPalette.accentRed
        saveButton.layer.cornerRadius = Radius.s12
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        view.addSubview(headerBar)
        view.addSubview(nameLabel)
        view.addSubview(nameField)
        view.addSubview(saveButton)
    }

    private func layoutViews() {
        headerBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.s8)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.height.equalTo(44)
        }
        titleLabel.snp.makeConstraints { $0.leading.centerY.equalToSuperview() }
        closeButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.size.equalTo(36)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(headerBar.snp.bottom).offset(Spacing.s24)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
        }
        nameField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(Spacing.s10)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.height.equalTo(48)
        }

        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Spacing.s16)
            make.height.equalTo(52)
        }
    }

    private func syncUI() {
        nameField.text = draftTitle
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func nameChanged() {
        draftTitle = nameField.text ?? ""
    }

    @objc private func saveTapped() {
        nameField.resignFirstResponder()
        onSave?(draftTitle.trimmingCharacters(in: .whitespacesAndNewlines))
        dismiss(animated: true)
    }
}

extension LineupEditorSettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveTapped()
        return true
    }
}
