//
//  CreateMatchViewController.swift
//  AppBase
//

import BaseMVVM
import SnapKit
import UIKit

final class CreateMatchViewController: FootballScreenViewController<CreateMatchViewModel> {

    var onContinue: (() -> Void)?
    var onPickHomeTeam: (() -> Void)?
    var onPickAwayTeam: (() -> Void)?

    private let scrollView = UIScrollView()
    private let formStack = UIStackView()
    private let homeField = MatchFormTextField()
    private let homeTeamActionsRow = UIStackView()
    private let pickHomeTeamButton = UIButton(type: .system)
    private let removeHomeTeamButton = UIButton(type: .system)
    private let awayField = MatchFormTextField()
    private let awayTeamActionsRow = UIStackView()
    private let pickAwayTeamButton = UIButton(type: .system)
    private let removeAwayTeamButton = UIButton(type: .system)
    private let datePicker = UIDatePicker()
    private let firstHalfStepper = MatchMinuteStepper(title: L10n.Football.Match.Create.firstHalf)
    private let secondHalfStepper = MatchMinuteStepper(title: L10n.Football.Match.Create.secondHalf)
    private let extraSwitch = UISwitch()
    private let extraLabel = UILabel()
    private let penaltySwitch = UISwitch()
    private let penaltyLabel = UILabel()
    private let pitchSizeStack = UIStackView()
    private var pitchSizeButtons: [MatchPitchSizeButton] = []
    private let continueButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadFromViewModel()
    }

    /// Cập nhật form sau khi chọn đội đã lưu (modal team picker).
    func reloadFromViewModel() {
        syncFromViewModel()
        updatePickTeamButtonTitles()
    }

    override func setupUI() {
        super.setupUI()
        title = L10n.Football.Match.Create.title

        formStack.axis = .vertical
        formStack.spacing = Spacing.s20

        homeField.placeholder = L10n.Football.Match.Create.homeTeam
        awayField.placeholder = L10n.Football.Match.Create.awayTeam
        configureTeamActionsRow(
            stack: homeTeamActionsRow,
            pickButton: pickHomeTeamButton,
            removeButton: removeHomeTeamButton,
            pickAction: #selector(pickHomeTeamTapped),
            removeAction: #selector(removeHomeTeamTapped)
        )
        configureTeamActionsRow(
            stack: awayTeamActionsRow,
            pickButton: pickAwayTeamButton,
            removeButton: removeAwayTeamButton,
            pickAction: #selector(pickAwayTeamTapped),
            removeAction: #selector(removeAwayTeamTapped)
        )

        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .compact
        datePicker.tintColor = FootballPalette.accentGreen

        configureToggleRow(label: extraLabel, switchControl: extraSwitch, text: L10n.Football.Match.Create.extraTime)
        configureToggleRow(label: penaltyLabel, switchControl: penaltySwitch, text: L10n.Football.Match.Create.penalty)

        pitchSizeStack.axis = .horizontal
        pitchSizeStack.spacing = Spacing.s10
        pitchSizeStack.distribution = .fillEqually
        pitchSizeButtons = MatchPitchSize.allCases.map { size in
            let button = MatchPitchSizeButton(size: size)
            button.addTarget(self, action: #selector(pitchSizeTapped(_:)), for: .touchUpInside)
            pitchSizeStack.addArrangedSubview(button)
            return button
        }

        continueButton.setTitleColor(FootballPalette.onAccent, for: .normal)
        continueButton.titleLabel?.font = FootballPalette.title(16)
        continueButton.backgroundColor = FootballPalette.accentRed
        continueButton.layer.cornerRadius = Radius.s12
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        formStack.addArrangedSubview(sectionLabel(L10n.Football.Match.Create.pitchSize))
        formStack.addArrangedSubview(pitchSizeStack)
        formStack.addArrangedSubview(sectionLabel(L10n.Football.Match.Create.teams))
        formStack.addArrangedSubview(homeField)
        formStack.addArrangedSubview(homeTeamActionsRow)
        formStack.addArrangedSubview(awayField)
        formStack.addArrangedSubview(awayTeamActionsRow)
        formStack.addArrangedSubview(sectionLabel(L10n.Football.Match.Create.kickoff))
        formStack.addArrangedSubview(datePicker)
        formStack.addArrangedSubview(sectionLabel(L10n.Football.Match.Create.duration))
        formStack.addArrangedSubview(firstHalfStepper)
        formStack.addArrangedSubview(secondHalfStepper)
        formStack.addArrangedSubview(toggleRow(extraLabel, extraSwitch))
        formStack.addArrangedSubview(toggleRow(penaltyLabel, penaltySwitch))

        scrollView.addSubview(formStack)
        view.addSubview(scrollView)
        view.addSubview(continueButton)

        formStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.s20)
            make.width.equalTo(scrollView.frameLayoutGuide).offset(-Spacing.s40)
        }
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(continueButton.snp.top).offset(-Spacing.s16)
        }
        continueButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Spacing.s16)
            make.height.equalTo(52)
        }

        reloadFromViewModel()
    }

    override func refreshLocalization() {
        title = L10n.Football.Match.Create.title
        homeField.placeholder = L10n.Football.Match.Create.homeTeam
        awayField.placeholder = L10n.Football.Match.Create.awayTeam
        configureToggleRow(label: extraLabel, switchControl: extraSwitch, text: L10n.Football.Match.Create.extraTime)
        configureToggleRow(label: penaltyLabel, switchControl: penaltySwitch, text: L10n.Football.Match.Create.penalty)
        continueButton.setTitle(L10n.Football.Match.Create.continueSetup, for: .normal)
        firstHalfStepper.updateTitle(L10n.Football.Match.Create.firstHalf)
        secondHalfStepper.updateTitle(L10n.Football.Match.Create.secondHalf)
        pitchSizeButtons.forEach { $0.refreshTitle() }
        updatePickTeamButtonTitles()
    }

    override func refreshFootballTheme() {
        super.refreshFootballTheme()
        continueButton.backgroundColor = FootballPalette.accentRed
        homeField.backgroundColor = FootballPalette.surface
        homeField.textColor = FootballPalette.textPrimary
        awayField.backgroundColor = FootballPalette.surface
        awayField.textColor = FootballPalette.textPrimary
        pitchSizeButtons.forEach { $0.refresh() }
        removeHomeTeamButton.tintColor = FootballPalette.accentRed
        removeAwayTeamButton.tintColor = FootballPalette.accentRed
    }

    private func syncFromViewModel() {
        homeField.text = viewModel.homeTeam
        awayField.text = viewModel.awayTeam
        datePicker.date = viewModel.kickoffDate
        firstHalfStepper.minutes = viewModel.firstHalfMinutes
        secondHalfStepper.minutes = viewModel.secondHalfMinutes
        extraSwitch.isOn = viewModel.hasExtraTime
        penaltySwitch.isOn = viewModel.hasPenaltyShootout
        syncPitchSizeSelection()
    }

    private func syncToViewModel() {
        viewModel.homeTeam = homeField.text ?? ""
        viewModel.awayTeam = awayField.text ?? ""
        viewModel.kickoffDate = datePicker.date
        viewModel.firstHalfMinutes = firstHalfStepper.minutes
        viewModel.secondHalfMinutes = secondHalfStepper.minutes
        viewModel.hasExtraTime = extraSwitch.isOn
        viewModel.hasPenaltyShootout = penaltySwitch.isOn
        viewModel.updateTeamNames()
    }

    private func syncPitchSizeSelection() {
        pitchSizeButtons.forEach { $0.isSelected = $0.pitchSize == viewModel.pitchSize }
    }

    @objc private func pitchSizeTapped(_ sender: MatchPitchSizeButton) {
        syncToViewModel()
        viewModel.setPitchSize(sender.pitchSize)
        syncPitchSizeSelection()
        reloadFromViewModel()
    }

    @objc private func continueTapped() {
        syncToViewModel()
        guard viewModel.canContinueToTeamSetup() else {
            viewModel.presentError(message: L10n.Football.Match.Create.validationTeams)
            return
        }
        onContinue?()
    }

    @objc private func pickHomeTeamTapped() {
        onPickHomeTeam?()
    }

    @objc private func pickAwayTeamTapped() {
        onPickAwayTeam?()
    }

    @objc private func removeHomeTeamTapped() {
        viewModel.clearImportedTeam(side: .home)
        reloadFromViewModel()
    }

    @objc private func removeAwayTeamTapped() {
        viewModel.clearImportedTeam(side: .away)
        reloadFromViewModel()
    }

    private func configureTeamActionsRow(
        stack: UIStackView,
        pickButton: UIButton,
        removeButton: UIButton,
        pickAction: Selector,
        removeAction: Selector
    ) {
        stack.axis = .horizontal
        stack.spacing = Spacing.s8
        stack.alignment = .center

        pickButton.addTarget(self, action: pickAction, for: .touchUpInside)

        removeButton.setImage(
            UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)),
            for: .normal
        )
        removeButton.tintColor = FootballPalette.accentRed
        removeButton.accessibilityLabel = L10n.Football.Match.Create.removeImported
        removeButton.addTarget(self, action: removeAction, for: .touchUpInside)
        removeButton.snp.makeConstraints { $0.size.equalTo(36) }

        stack.addArrangedSubview(pickButton)
        stack.addArrangedSubview(removeButton)
    }

    private func updatePickTeamButtonTitles() {
        let homeTitle = viewModel.hasImportedTemplate(side: .home)
            ? L10n.Football.Match.Create.teamImported(viewModel.homeTeam)
            : L10n.Football.Teams.pickForMatch
        let awayTitle = viewModel.hasImportedTemplate(side: .away)
            ? L10n.Football.Match.Create.teamImported(viewModel.awayTeam)
            : L10n.Football.Teams.pickForMatch
        stylePickTeamButton(pickHomeTeamButton, title: homeTitle, linked: viewModel.hasImportedTemplate(side: .home))
        stylePickTeamButton(pickAwayTeamButton, title: awayTitle, linked: viewModel.hasImportedTemplate(side: .away))
        removeHomeTeamButton.isHidden = !viewModel.hasImportedTemplate(side: .home)
        removeAwayTeamButton.isHidden = !viewModel.hasImportedTemplate(side: .away)
    }

    private func stylePickTeamButton(_ button: UIButton, title: String, linked: Bool = false) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = FootballPalette.caption(13)
        button.titleLabel?.numberOfLines = 2
        button.setTitleColor(linked ? FootballPalette.accentGreen : FootballPalette.textSecondary, for: .normal)
        button.contentHorizontalAlignment = .leading
    }

    private func sectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = FootballPalette.caption()
        label.textColor = FootballPalette.textSecondary
        return label
    }

    private func configureToggleRow(label: UILabel, switchControl: UISwitch, text: String) {
        label.text = text
        label.font = FootballPalette.title(15)
        label.textColor = FootballPalette.textPrimary
        switchControl.onTintColor = FootballPalette.accentGreen
    }

    private func toggleRow(_ label: UILabel, _ toggle: UISwitch) -> UIView {
        let row = UIView()
        row.addSubview(label)
        row.addSubview(toggle)
        label.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(toggle.snp.leading).offset(-Spacing.s12)
        }
        toggle.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
        }
        row.snp.makeConstraints { $0.height.equalTo(44) }
        return row
    }
}

// MARK: - Form controls

private final class MatchFormTextField: UITextField {

    init() {
        super.init(frame: .zero)
        backgroundColor = FootballPalette.surface
        textColor = FootballPalette.textPrimary
        font = FootballPalette.title(16)
        layer.cornerRadius = Radius.s12
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: Spacing.s12, height: 1))
        leftViewMode = .always
        snp.makeConstraints { $0.height.equalTo(48) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class MatchMinuteStepper: UIView {

    var minutes: Int {
        get { Int(valueLabel.text ?? "45") ?? 45 }
        set { valueLabel.text = "\(newValue)" }
    }

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let minusButton = UIButton(type: .system)
    private let plusButton = UIButton(type: .system)

    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = FootballPalette.surface
        layer.cornerRadius = Radius.s12

        titleLabel.text = title
        titleLabel.font = FootballPalette.caption()
        titleLabel.textColor = FootballPalette.textSecondary

        valueLabel.font = FootballPalette.title(18)
        valueLabel.textColor = FootballPalette.textPrimary
        valueLabel.textAlignment = .center
        valueLabel.text = "45"

        minusButton.setTitle("−", for: .normal)
        plusButton.setTitle("+", for: .normal)
        [minusButton, plusButton].forEach {
            $0.titleLabel?.font = FootballPalette.title(20)
            $0.tintColor = FootballPalette.accentGreen
        }
        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)

        addSubview(titleLabel)
        addSubview(minusButton)
        addSubview(valueLabel)
        addSubview(plusButton)

        snp.makeConstraints { $0.height.equalTo(52) }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.s12)
            make.centerY.equalToSuperview()
        }
        plusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Spacing.s8)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
        }
        valueLabel.snp.makeConstraints { make in
            make.trailing.equalTo(plusButton.snp.leading)
            make.centerY.equalToSuperview()
            make.width.equalTo(36)
        }
        minusButton.snp.makeConstraints { make in
            make.trailing.equalTo(valueLabel.snp.leading)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func minusTapped() {
        minutes = max(1, minutes - 1)
    }

    @objc private func plusTapped() {
        minutes = min(90, minutes + 1)
    }

    func updateTitle(_ text: String) {
        titleLabel.text = text
    }
}
