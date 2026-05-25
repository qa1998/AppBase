//
//  PitchOptionsViewController.swift
//  AppBase
//

import Combine
import SnapKit
import UIKit

/// Bottom sheet — pitch surface style and grid for the editor field.
final class PitchOptionsViewController: UIViewController, FootballChromeRefreshable {

    private var chromeCancel = Set<AnyCancellable>()

    var onSave: ((PitchDisplayOptions) -> Void)?

    private var draft: PitchDisplayOptions

    private let headerBar = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let styleStack = UIStackView()
    private var styleButtons: [PitchStyleOptionButton] = []
    private let gridSwitch = UISwitch()
    private let gridLabel = UILabel()
    private let saveButton = UIButton(type: .system)

    init(options: PitchDisplayOptions = LineupStore.shared.pitchDisplayOptions) {
        draft = options
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        installFootballChromeObservers(storage: &chromeCancel)
        setupSheet()
        buildUI()
        layoutViews()
        refreshFootballAppearance()
        syncUI()
    }

    func refreshFootballLocalization() {
        titleLabel.text = L10n.Football.PitchOptions.title
        gridLabel.text = L10n.Football.PitchOptions.showGrid
        saveButton.setTitle(L10n.Football.PitchOptions.save, for: .normal)
        styleButtons.forEach { $0.refreshTitle() }
    }

    func refreshFootballAppearance() {
        view.backgroundColor = FootballPalette.background
        titleLabel.textColor = FootballPalette.textPrimary
        closeButton.tintColor = FootballPalette.textPrimary
        gridLabel.textColor = FootballPalette.textPrimary
        gridSwitch.onTintColor = FootballPalette.accentGreen
        saveButton.backgroundColor = FootballPalette.accentRed
        saveButton.setTitleColor(FootballPalette.onAccent, for: .normal)
        styleButtons.forEach { $0.applyTheme() }
        refreshFootballLocalization()
    }

    private func setupSheet() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = Radius.s20
        }
    }

    private func buildUI() {
        titleLabel.font = FootballPalette.title(18)
        titleLabel.textColor = FootballPalette.textPrimary

        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = FootballPalette.textPrimary
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        headerBar.addSubview(titleLabel)
        headerBar.addSubview(closeButton)

        styleStack.axis = .vertical
        styleStack.spacing = Spacing.s10
        PitchSurfaceStyle.allCases.forEach { style in
            let button = PitchStyleOptionButton(style: style)
            button.addTarget(self, action: #selector(styleTapped(_:)), for: .touchUpInside)
            styleButtons.append(button)
            styleStack.addArrangedSubview(button)
        }

        gridLabel.font = FootballPalette.title(15)
        gridSwitch.addTarget(self, action: #selector(gridChanged), for: .valueChanged)

        saveButton.titleLabel?.font = FootballPalette.title(16)
        saveButton.layer.cornerRadius = Radius.s12
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        view.addSubview(headerBar)
        view.addSubview(styleStack)
        view.addSubview(gridLabel)
        view.addSubview(gridSwitch)
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

        styleStack.snp.makeConstraints { make in
            make.top.equalTo(headerBar.snp.bottom).offset(Spacing.s20)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
        }
        styleButtons.forEach { $0.snp.makeConstraints { $0.height.equalTo(52) } }

        gridLabel.snp.makeConstraints { make in
            make.top.equalTo(styleStack.snp.bottom).offset(Spacing.s24)
            make.leading.equalToSuperview().inset(Spacing.s20)
        }
        gridSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(gridLabel)
            make.trailing.equalToSuperview().inset(Spacing.s20)
        }

        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Spacing.s16)
            make.height.equalTo(52)
        }
    }

    private func syncUI() {
        styleButtons.forEach { $0.isSelected = $0.style == draft.surfaceStyle }
        gridSwitch.isOn = draft.showsGrid
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func styleTapped(_ sender: PitchStyleOptionButton) {
        draft.surfaceStyle = sender.style
        syncUI()
    }

    @objc private func gridChanged() {
        draft.showsGrid = gridSwitch.isOn
    }

    @objc private func saveTapped() {
        onSave?(draft)
        dismiss(animated: true)
    }
}

private final class PitchStyleOptionButton: UIControl {

    let style: PitchSurfaceStyle
    private let titleLabel = UILabel()
    private let preview = FootballPitchView()

    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected ? 2 : 0
            layer.borderColor = FootballPalette.accentGreen.cgColor
        }
    }

    init(style: PitchSurfaceStyle) {
        self.style = style
        super.init(frame: .zero)
        backgroundColor = FootballPalette.surface
        layer.cornerRadius = Radius.s12
        isUserInteractionEnabled = true

        titleLabel.font = FootballPalette.title(15)
        titleLabel.textColor = FootballPalette.textPrimary
        refreshTitle()

        preview.isUserInteractionEnabled = false
        preview.displayOptions = PitchDisplayOptions(surfaceStyle: style, showsGrid: true)

        addSubview(preview)
        addSubview(titleLabel)
        preview.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.s12)
            make.centerY.equalToSuperview()
            make.width.equalTo(56)
            make.height.equalTo(40)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(preview.snp.trailing).offset(Spacing.s12)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().inset(Spacing.s12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refreshTitle() {
        titleLabel.text = style.label
    }

    func applyTheme() {
        backgroundColor = FootballPalette.surface
        titleLabel.textColor = FootballPalette.textPrimary
        layer.borderColor = isSelected ? FootballPalette.accentGreen.cgColor : UIColor.clear.cgColor
        preview.setNeedsDisplay()
    }
}

private extension PitchSurfaceStyle {
    var label: String {
        switch self {
        case .full: return L10n.Football.PitchOptions.Style.full
        case .half: return L10n.Football.PitchOptions.Style.half
        case .futsal: return L10n.Football.PitchOptions.Style.futsal
        }
    }
}
