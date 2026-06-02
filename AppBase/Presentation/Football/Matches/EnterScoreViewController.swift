//
//  EnterScoreViewController.swift
//  AppBase
//

import BaseMVVM
import SnapKit
import UIKit

final class EnterScoreViewController: FootballScreenViewController<EnterScoreViewModel> {

    var onSaved: (() -> Void)?

    private let scrollView = UIScrollView()
    private let formStack = UIStackView()
    private let homeField = ScoreFormTextField()
    private let awayField = ScoreFormTextField()
    private let homeGoalsStepper = ScoreGoalsStepper(title: L10n.Football.Score.homeGoals)
    private let awayGoalsStepper = ScoreGoalsStepper(title: L10n.Football.Score.awayGoals)
    private let saveButton = UIButton(type: .system)

    override func setupUI() {
        super.setupUI()
        title = viewModel.isEditing
            ? L10n.Football.Score.editTitle
            : L10n.Football.Score.title

        formStack.axis = .vertical
        formStack.spacing = Spacing.s20

        homeField.placeholder = L10n.Football.Match.Create.homeTeam
        awayField.placeholder = L10n.Football.Match.Create.awayTeam

        saveButton.setTitle(L10n.Football.Score.save, for: .normal)
        saveButton.setTitleColor(FootballPalette.onAccent, for: .normal)
        saveButton.titleLabel?.font = FootballPalette.title(16)
        saveButton.backgroundColor = FootballPalette.accentRed
        saveButton.layer.cornerRadius = Radius.s12
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        formStack.addArrangedSubview(sectionLabel(L10n.Football.Match.Create.teams))
        formStack.addArrangedSubview(homeField)
        formStack.addArrangedSubview(awayField)
        formStack.addArrangedSubview(sectionLabel(L10n.Football.Score.scoreSection))
        formStack.addArrangedSubview(homeGoalsStepper)
        formStack.addArrangedSubview(awayGoalsStepper)

        scrollView.addSubview(formStack)
        view.addSubview(scrollView)
        view.addSubview(saveButton)

        formStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.s20)
            make.width.equalTo(scrollView.frameLayoutGuide).offset(-Spacing.s40)
        }
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(saveButton.snp.top).offset(-Spacing.s16)
        }
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Spacing.s16)
            make.height.equalTo(52)
        }

        syncFromViewModel()
    }

    override func refreshLocalization() {
        title = viewModel.isEditing
            ? L10n.Football.Score.editTitle
            : L10n.Football.Score.title
        homeField.placeholder = L10n.Football.Match.Create.homeTeam
        awayField.placeholder = L10n.Football.Match.Create.awayTeam
        homeGoalsStepper.updateTitle(L10n.Football.Score.homeGoals)
        awayGoalsStepper.updateTitle(L10n.Football.Score.awayGoals)
        saveButton.setTitle(L10n.Football.Score.save, for: .normal)
    }

    override func refreshFootballTheme() {
        super.refreshFootballTheme()
        saveButton.backgroundColor = FootballPalette.accentRed
        homeField.backgroundColor = FootballPalette.surface
        homeField.textColor = FootballPalette.textPrimary
        awayField.backgroundColor = FootballPalette.surface
        awayField.textColor = FootballPalette.textPrimary
    }

    private func syncFromViewModel() {
        homeField.text = viewModel.homeTeam
        awayField.text = viewModel.awayTeam
        homeGoalsStepper.goals = viewModel.homeGoals
        awayGoalsStepper.goals = viewModel.awayGoals
    }

    private func syncToViewModel() {
        viewModel.homeTeam = homeField.text ?? ""
        viewModel.awayTeam = awayField.text ?? ""
        viewModel.homeGoals = homeGoalsStepper.goals
        viewModel.awayGoals = awayGoalsStepper.goals
    }

    @objc private func saveTapped() {
        view.endEditing(true)
        syncToViewModel()
        guard viewModel.save() else { return }
        onSaved?()
    }

    private func sectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = FootballPalette.caption()
        label.textColor = FootballPalette.textSecondary
        return label
    }
}

// MARK: - Controls

private final class ScoreFormTextField: UITextField {

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

private final class ScoreGoalsStepper: UIView, UITextFieldDelegate {

    var goals: Int {
        get { Self.parseGoals(from: valueField.text) }
        set { valueField.text = "\(max(0, min(99, newValue)))" }
    }

    private let titleLabel = UILabel()
    private let valueField = UITextField()
    private let minusButton = UIButton(type: .system)
    private let plusButton = UIButton(type: .system)

    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = FootballPalette.surface
        layer.cornerRadius = Radius.s12

        titleLabel.text = title
        titleLabel.font = FootballPalette.caption()
        titleLabel.textColor = FootballPalette.textSecondary

        valueField.font = FootballPalette.headline(28)
        valueField.textColor = FootballPalette.accentGreen
        valueField.textAlignment = .center
        valueField.keyboardType = .numberPad
        valueField.text = "0"
        valueField.delegate = self
        valueField.inputAccessoryView = ScoreNumberPadToolbar { [weak self] in
            self?.valueField.resignFirstResponder()
            self?.goals = Self.parseGoals(from: self?.valueField.text)
        }
        valueField.addTarget(self, action: #selector(valueFieldChanged), for: .editingChanged)

        minusButton.setTitle("−", for: .normal)
        plusButton.setTitle("+", for: .normal)
        [minusButton, plusButton].forEach {
            $0.titleLabel?.font = FootballPalette.title(24)
            $0.tintColor = FootballPalette.accentGreen
        }
        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)

        addSubview(titleLabel)
        addSubview(minusButton)
        addSubview(valueField)
        addSubview(plusButton)

        snp.makeConstraints { $0.height.equalTo(56) }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.s12)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(minusButton.snp.leading).offset(-Spacing.s8)
        }
        plusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Spacing.s8)
            make.centerY.equalToSuperview()
            make.width.equalTo(44)
        }
        valueField.snp.makeConstraints { make in
            make.trailing.equalTo(plusButton.snp.leading)
            make.centerY.equalToSuperview()
            make.width.equalTo(56)
            make.height.equalTo(40)
        }
        minusButton.snp.makeConstraints { make in
            make.trailing.equalTo(valueField.snp.leading)
            make.centerY.equalToSuperview()
            make.width.equalTo(44)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTitle(_ text: String) {
        titleLabel.text = text
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        goals = Self.parseGoals(from: textField.text)
    }

    @objc private func valueFieldChanged() {
        let raw = valueField.text ?? ""
        let filtered = raw.filter(\.isNumber)
        if filtered != raw {
            valueField.text = filtered
        }
    }

    @objc private func minusTapped() {
        valueField.resignFirstResponder()
        goals = max(0, goals - 1)
    }

    @objc private func plusTapped() {
        valueField.resignFirstResponder()
        goals = min(99, goals + 1)
    }

    private static func parseGoals(from text: String?) -> Int {
        let digits = (text ?? "").filter(\.isNumber)
        guard let value = Int(digits), value >= 0 else { return 0 }
        return min(99, value)
    }
}

private final class ScoreNumberPadToolbar: UIToolbar {

    init(onDone: @escaping () -> Void) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(
            __barButtonSystemItem: .done,
            primaryAction: UIAction { _ in onDone() }
        )
        items = [flex, done]
        sizeToFit()
        tintColor = FootballPalette.accentGreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
