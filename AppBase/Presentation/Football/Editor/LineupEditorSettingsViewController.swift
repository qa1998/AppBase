//
//  LineupEditorSettingsViewController.swift
//  AppBase
//

import BaseMVVM
import SnapKit
import UIKit

/// Pushed screen — tactical / lineup metadata (name and more fields later).
final class LineupEditorSettingsViewController: FootballScreenViewController<LineupEditorSettingsViewModel> {

    var onDidSave: (() -> Void)?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let fieldsStack = UIStackView()
    private let nameLabel = UILabel()
    private let nameFieldContainer = UIView()
    private let nameField = UITextField()
    private let saveButton = UIButton(type: .system)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func setupUI() {
        super.setupUI()
        buildUI()
        layoutViews()
        applyNameFieldStyle()
        refreshLocalization()
        saveButton.backgroundColor = FootballPalette.accentRed
    }

    override func onBind() {
        super.onBind()
        nameField.text = viewModel.initialTitle
    }

    override func refreshLocalization() {
        navigationItem.title = L10n.Football.Editor.Settings.title
        nameLabel.text = L10n.Football.Editor.Settings.nameLabel
        saveButton.setTitle(L10n.Football.Editor.Settings.save, for: .normal)
        applyNameFieldStyle()
    }

    override func refreshFootballTheme() {
        super.refreshFootballTheme()
        nameLabel.textColor = FootballPalette.textSecondary
        applyNameFieldStyle()
        saveButton.backgroundColor = FootballPalette.accentRed
    }

    private func applyNameFieldStyle() {
        nameFieldContainer.backgroundColor = FootballPalette.surfaceElevated
        nameFieldContainer.layer.borderColor = FootballPalette.glassBorder.cgColor
        nameField.textColor = FootballPalette.textPrimary
        nameField.tintColor = FootballPalette.accentGreen
        let placeholderColor = FootballPalette.textSecondary
        nameField.attributedPlaceholder = NSAttributedString(
            string: L10n.Football.Editor.Settings.namePlaceholder,
            attributes: [.foregroundColor: placeholderColor]
        )
    }

    private func buildUI() {
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive

        fieldsStack.axis = .vertical
        fieldsStack.spacing = Spacing.s10
        fieldsStack.alignment = .fill

        nameLabel.font = FootballPalette.title(15)

        nameFieldContainer.layer.cornerRadius = Radius.s12
        nameFieldContainer.layer.borderWidth = 1

        nameField.borderStyle = .none
        nameField.backgroundColor = .clear
        nameField.font = FootballPalette.title(16)
        nameField.autocapitalizationType = .words
        nameField.returnKeyType = .done
        nameField.clearButtonMode = .whileEditing
        nameField.delegate = self

        nameFieldContainer.addSubview(nameField)

        fieldsStack.addArrangedSubview(nameLabel)
        fieldsStack.addArrangedSubview(nameFieldContainer)
        nameFieldContainer.snp.makeConstraints { $0.height.equalTo(48) }
        nameField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.s12)
            make.top.bottom.equalToSuperview()
        }

        saveButton.setTitleColor(FootballPalette.onAccent, for: .normal)
        saveButton.titleLabel?.font = FootballPalette.title(16)
        saveButton.layer.cornerRadius = Radius.s12
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        contentView.addSubview(fieldsStack)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        view.addSubview(saveButton)
    }

    private func layoutViews() {
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Spacing.s16)
            make.height.equalTo(52)
        }

        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(saveButton.snp.top).offset(-Spacing.s16)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }

        fieldsStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.s24)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.bottom.equalToSuperview().inset(Spacing.s24)
        }
    }

    @objc private func saveTapped() {
        nameField.resignFirstResponder()
        let title = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.saveTitle(title)
        onDidSave?()
        navigationController?.popViewController(animated: true)
    }
}

extension LineupEditorSettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveTapped()
        return true
    }
}
