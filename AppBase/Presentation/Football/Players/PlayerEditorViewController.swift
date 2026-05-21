//
//  PlayerEditorViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import SnapKit
import UIKit

final class PlayerEditorViewController: FootballScreenViewController<PlayerEditorViewModel> {

    var onSaved: (() -> Void)?

    private let headerBar = UIView()
    private let backButton = UIButton(type: .system)
    private let headerTitleLabel = UILabel()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let avatarButton = UIButton(type: .custom)
    private let avatarImageView = UIImageView()
    private let avatarHintLabel = UILabel()
    private let nameField = UITextField()
    private let jerseyTitleLabel = UILabel()
    private let jerseyField = UITextField()
    private let positionTitleLabel = UILabel()
    private let positionStack = UIStackView()
    private var positionButtons: [UIButton] = []
    private let saveButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func setupUI() {
        super.setupUI()
        buildHeader()
        buildForm()
        layoutChrome()
        syncFromPlayer(viewModel.player)
    }

    override func refreshLocalization() {
        headerTitleLabel.text = L10n.Football.Players.editorTitle
        avatarHintLabel.text = L10n.Football.Players.avatarHint
        nameField.placeholder = L10n.Football.Players.namePlaceholder
        jerseyTitleLabel.text = L10n.Football.Players.jerseyTitle
        jerseyField.placeholder = L10n.Football.Players.jerseyPlaceholder
        positionTitleLabel.text = L10n.Football.Players.positionTitle
        saveButton.setTitle(L10n.Football.Players.save.uppercased(), for: .normal)
    }

    override func onBind() {
        super.onBind()
        viewModel.$player
            .receive(on: DispatchQueue.main)
            .sink { [weak self] player in
                self?.syncFromPlayer(player)
            }
            .store(in: &cancelBag)
    }

    private func buildHeader() {
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = FootballPalette.textPrimary
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        headerTitleLabel.font = FootballPalette.title(17)
        headerTitleLabel.textColor = FootballPalette.textPrimary
        headerTitleLabel.textAlignment = .center
        headerBar.addSubview(backButton)
        headerBar.addSubview(headerTitleLabel)
        view.addSubview(headerBar)
        backButton.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(44)
        }
        headerTitleLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        headerBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
    }

    private func buildForm() {
        contentStack.axis = .vertical
        contentStack.spacing = Spacing.s16

        avatarButton.layer.cornerRadius = 48
        avatarButton.clipsToBounds = true
        avatarButton.backgroundColor = FootballPalette.surface
        avatarButton.addTarget(self, action: #selector(avatarTapped), for: .touchUpInside)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.isUserInteractionEnabled = false
        avatarButton.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { $0.edges.equalToSuperview() }

        avatarHintLabel.font = FootballPalette.caption()
        avatarHintLabel.textColor = FootballPalette.textSecondary
        avatarHintLabel.textAlignment = .center

        nameField.font = FootballPalette.title(16)
        nameField.textColor = FootballPalette.textPrimary
        nameField.backgroundColor = FootballPalette.surface
        nameField.layer.cornerRadius = Radius.s12
        nameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        nameField.leftViewMode = .always
        nameField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)

        jerseyTitleLabel.font = FootballPalette.caption()
        jerseyTitleLabel.textColor = FootballPalette.textSecondary
        jerseyField.font = FootballPalette.title(16)
        jerseyField.textColor = FootballPalette.textPrimary
        jerseyField.backgroundColor = FootballPalette.surface
        jerseyField.layer.cornerRadius = Radius.s12
        jerseyField.keyboardType = .numberPad
        jerseyField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        jerseyField.leftViewMode = .always
        jerseyField.addTarget(self, action: #selector(jerseyChanged), for: .editingChanged)

        positionTitleLabel.font = FootballPalette.caption()
        positionTitleLabel.textColor = FootballPalette.textSecondary
        positionStack.axis = .horizontal
        positionStack.spacing = Spacing.s8
        positionStack.distribution = .fillEqually
        positionButtons = FootballPosition.allCases.map { position in
            let button = UIButton(type: .system)
            button.setTitle(position.label, for: .normal)
            button.titleLabel?.font = FootballPalette.title(14)
            button.layer.cornerRadius = Radius.s12
            button.tag = FootballPosition.allCases.firstIndex(of: position) ?? 0
            button.addTarget(self, action: #selector(positionTapped(_:)), for: .touchUpInside)
            positionStack.addArrangedSubview(button)
            return button
        }

        saveButton.backgroundColor = FootballPalette.accentRed
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = FootballPalette.title(16)
        saveButton.layer.cornerRadius = Radius.s12
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        let avatarRow = UIView()
        avatarRow.addSubview(avatarButton)
        avatarButton.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.size.equalTo(96)
        }
        avatarRow.snp.makeConstraints { $0.height.equalTo(96) }

        contentStack.addArrangedSubview(avatarRow)
        contentStack.addArrangedSubview(avatarHintLabel)
        contentStack.addArrangedSubview(nameField)
        contentStack.addArrangedSubview(jerseyTitleLabel)
        contentStack.addArrangedSubview(jerseyField)
        contentStack.addArrangedSubview(positionTitleLabel)
        contentStack.addArrangedSubview(positionStack)
        nameField.snp.makeConstraints { $0.height.equalTo(48) }
        jerseyField.snp.makeConstraints { $0.height.equalTo(48) }
        positionStack.snp.makeConstraints { $0.height.equalTo(44) }

        scrollView.addSubview(contentStack)
        view.addSubview(scrollView)
        view.addSubview(saveButton)
    }

    private func layoutChrome() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerBar.snp.bottom).offset(Spacing.s8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(saveButton.snp.top).offset(-Spacing.s12)
        }
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(
                top: Spacing.s16,
                left: Spacing.s20,
                bottom: Spacing.s16,
                right: Spacing.s20
            ))
            make.width.equalTo(scrollView.frameLayoutGuide).offset(-Spacing.s40)
        }
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Spacing.s16)
            make.height.equalTo(52)
        }
    }

    private func syncFromPlayer(_ player: FootballPlayer) {
        nameField.text = player.name
        if let number = player.jerseyNumber, number > 0 {
            jerseyField.text = "\(number)"
        } else {
            jerseyField.text = ""
        }
        if let image = player.avatarImage {
            avatarImageView.image = image
            avatarImageView.isHidden = false
            avatarButton.setTitle(nil, for: .normal)
        } else {
            avatarImageView.image = nil
            avatarImageView.isHidden = true
            avatarButton.setTitle(player.initials.isEmpty ? "+" : player.initials, for: .normal)
            avatarButton.setTitleColor(FootballPalette.textSecondary, for: .normal)
            avatarButton.titleLabel?.font = FootballPalette.headline(24)
        }
        positionButtons.enumerated().forEach { index, button in
            let selected = FootballPosition.allCases[index] == player.position
            button.backgroundColor = selected ? FootballPalette.accentGreen : FootballPalette.surface
            button.setTitleColor(selected ? .white : FootballPalette.textPrimary, for: .normal)
        }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func nameChanged() {
        viewModel.updateName(nameField.text ?? "")
    }

    @objc private func jerseyChanged() {
        let text = jerseyField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if text.isEmpty {
            viewModel.setJerseyNumber(nil)
            return
        }
        viewModel.setJerseyNumber(Int(text))
    }

    @objc private func positionTapped(_ sender: UIButton) {
        let position = FootballPosition.allCases[sender.tag]
        viewModel.setPosition(position)
    }

    @objc private func avatarTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    @objc private func saveTapped() {
        guard viewModel.save() else { return }
        onSaved?()
    }
}

extension PlayerEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)
        let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        guard let image else { return }
        viewModel.setAvatar(image)
    }
}
