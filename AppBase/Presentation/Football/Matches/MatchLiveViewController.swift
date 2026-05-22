//
//  MatchLiveViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import SnapKit
import UIKit

final class MatchLiveViewController: FootballScreenViewController<MatchLiveViewModel> {

    private let headerCard = UIView()
    private let homeLabel = UILabel()
    private let awayLabel = UILabel()
    private let scoreLabel = UILabel()
    private let clockLabel = UILabel()
    private let phaseLabel = UILabel()
    private let primaryButton = UIButton(type: .system)
    private let actionsScroll = UIScrollView()
    private let actionsStack = UIStackView()
    private let tableView = UITableView(frame: .zero, style: .grouped)

    private var actionsBarHeightConstraint: Constraint?
    private var actionsTopSpacingConstraint: Constraint?
    private var tableTopToActionsConstraint: Constraint?
    private var tableTopToHeaderConstraint: Constraint?
    private var primaryButtonHeightConstraint: Constraint?
    private var primaryButtonTopConstraint: Constraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func setupUI() {
        super.setupUI()
        let s = viewModel.match.settings
        title = "\(s.homeTeam) vs \(s.awayTeam)"
        buildHeader()
        buildActions()
        buildTable()
        layoutViews()
        refreshMatchHeader()
        setPrimaryButtonVisible(viewModel.primaryButtonTitle != nil)
        setQuickActionsVisible(viewModel.showQuickActions)
    }

    override func onBind() {
        super.onBind()
        viewModel.$clockText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.clockLabel.text = $0 }
            .store(in: &cancelBag)
        viewModel.$phaseTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.phaseLabel.text = $0 }
            .store(in: &cancelBag)
        viewModel.$primaryButtonTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.primaryButton.setTitle(title, for: .normal)
                self?.setPrimaryButtonVisible(title != nil)
            }
            .store(in: &cancelBag)
        viewModel.$showQuickActions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                self?.setQuickActionsVisible(show)
            }
            .store(in: &cancelBag)
        viewModel.$timelineSections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancelBag)
        Publishers.CombineLatest(viewModel.$match, viewModel.$timelineSections)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.refreshMatchHeader()
            }
            .store(in: &cancelBag)
    }

    private func buildHeader() {
        headerCard.backgroundColor = FootballPalette.surface
        headerCard.layer.cornerRadius = Radius.s16

        homeLabel.font = FootballPalette.title(17)
        homeLabel.textColor = FootballPalette.textPrimary
        awayLabel.font = FootballPalette.title(17)
        awayLabel.textColor = FootballPalette.textPrimary
        awayLabel.textAlignment = .right

        scoreLabel.font = FootballPalette.headline(28)
        scoreLabel.textColor = FootballPalette.accentGreen
        scoreLabel.textAlignment = .center

        clockLabel.font = FootballPalette.headline(36)
        clockLabel.textColor = FootballPalette.textPrimary
        clockLabel.textAlignment = .center

        phaseLabel.font = FootballPalette.caption()
        phaseLabel.textColor = FootballPalette.textSecondary
        phaseLabel.textAlignment = .center
        phaseLabel.numberOfLines = 0

        primaryButton.backgroundColor = FootballPalette.accentRed
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.titleLabel?.font = FootballPalette.title(16)
        primaryButton.layer.cornerRadius = Radius.s12
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)

        headerCard.addSubview(homeLabel)
        headerCard.addSubview(scoreLabel)
        headerCard.addSubview(awayLabel)
        headerCard.addSubview(clockLabel)
        headerCard.addSubview(phaseLabel)
        headerCard.addSubview(primaryButton)
        view.addSubview(headerCard)
    }

    private func buildActions() {
        actionsStack.axis = .horizontal
        actionsStack.spacing = Spacing.s8
        actionsScroll.showsHorizontalScrollIndicator = false
        actionsScroll.addSubview(actionsStack)
        actionsStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: Spacing.s16, bottom: 0, right: Spacing.s16))
            make.height.equalToSuperview()
        }

        MatchEventType.allCases.forEach { type in
            let button = UIButton(type: .system)
            button.setTitle(actionTitle(type), for: .normal)
            button.titleLabel?.font = FootballPalette.caption(12)
            button.setTitleColor(FootballPalette.textPrimary, for: .normal)
            button.backgroundColor = FootballPalette.surfaceElevated
            button.layer.cornerRadius = Radius.s12
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
            button.tag = typeTag(type)
            button.addTarget(self, action: #selector(actionTapped(_:)), for: .touchUpInside)
            actionsStack.addArrangedSubview(button)
        }
        view.addSubview(actionsScroll)
    }

    private func buildTable() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MatchTimelineHalfCell.self, forCellReuseIdentifier: MatchTimelineHalfCell.reuseId)
        view.addSubview(tableView)
    }

    private func layoutViews() {
        headerCard.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.s12)
            make.leading.trailing.equalToSuperview().inset(Spacing.s16)
        }
        homeLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.s16)
            make.trailing.lessThanOrEqualTo(scoreLabel.snp.leading).offset(-Spacing.s8)
        }
        scoreLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Spacing.s16)
        }
        awayLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(Spacing.s16)
            make.leading.greaterThanOrEqualTo(scoreLabel.snp.trailing).offset(Spacing.s8)
        }
        clockLabel.snp.makeConstraints { make in
            make.top.equalTo(scoreLabel.snp.bottom).offset(Spacing.s16)
            make.centerX.equalToSuperview()
        }
        phaseLabel.snp.makeConstraints { make in
            make.top.equalTo(clockLabel.snp.bottom).offset(Spacing.s6)
            make.leading.trailing.equalToSuperview().inset(Spacing.s16)
        }
        primaryButton.snp.makeConstraints { make in
            primaryButtonTopConstraint = make.top.equalTo(phaseLabel.snp.bottom).offset(Spacing.s16).constraint
            make.leading.trailing.equalToSuperview().inset(Spacing.s16)
            make.bottom.equalToSuperview().inset(Spacing.s16)
            primaryButtonHeightConstraint = make.height.equalTo(48).constraint
        }
        actionsScroll.snp.makeConstraints { make in
            actionsTopSpacingConstraint = make.top.equalTo(headerCard.snp.bottom).offset(Spacing.s12).constraint
            make.leading.trailing.equalToSuperview()
            actionsBarHeightConstraint = make.height.equalTo(44).constraint
        }
        tableView.snp.makeConstraints { make in
            tableTopToActionsConstraint = make.top.equalTo(actionsScroll.snp.bottom).offset(Spacing.s8).constraint
            tableTopToHeaderConstraint = make.top.equalTo(headerCard.snp.bottom).offset(Spacing.s12).constraint
            tableTopToHeaderConstraint?.deactivate()
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setQuickActionsVisible(_ visible: Bool) {
        actionsScroll.isHidden = !visible
        actionsBarHeightConstraint?.update(offset: visible ? 44 : 0)
        actionsTopSpacingConstraint?.update(offset: visible ? Spacing.s12 : 0)

        if visible {
            tableTopToHeaderConstraint?.deactivate()
            tableTopToActionsConstraint?.activate()
        } else {
            tableTopToActionsConstraint?.deactivate()
            tableTopToHeaderConstraint?.activate()
        }
        animateLayoutRefresh()
    }

    private func setPrimaryButtonVisible(_ visible: Bool) {
        primaryButton.isHidden = !visible
        primaryButtonHeightConstraint?.update(offset: visible ? 48 : 0)
        primaryButtonTopConstraint?.update(offset: visible ? Spacing.s16 : 0)
        animateLayoutRefresh()
    }

    private func animateLayoutRefresh() {
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
        }
    }

    private func refreshMatchHeader() {
        let m = viewModel.match
        homeLabel.text = m.settings.homeTeam
        awayLabel.text = m.settings.awayTeam
        scoreLabel.text = m.scoreLine
    }

    @objc private func primaryTapped() {
        viewModel.performPrimaryAction()
    }

    @objc private func actionTapped(_ sender: UIButton) {
        guard let type = typeFromTag(sender.tag) else { return }
        pickTeam(for: type)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            viewModel.persistState()
        }
    }

    private func pickTeam(for type: MatchEventType) {
        let sheet = UIAlertController(title: actionTitle(type), message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: viewModel.match.settings.homeTeam, style: .default) { [weak self] _ in
            self?.pickPlayer(for: type, team: .home)
        })
        sheet.addAction(UIAlertAction(title: viewModel.match.settings.awayTeam, style: .default) { [weak self] _ in
            self?.pickPlayer(for: type, team: .away)
        })
        if type == .varReview {
            sheet.addAction(UIAlertAction(title: L10n.Football.Match.Event.neutral, style: .default) { [weak self] _ in
                self?.viewModel.addEvent(type, team: .neutral, player: .neutralEvent)
            })
        }
        sheet.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        if let pop = sheet.popoverPresentationController {
            pop.sourceView = view
            pop.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        }
        present(sheet, animated: true)
    }

    private func pickPlayer(for type: MatchEventType, team: MatchTeamSide) {
        let players = viewModel.rosterPlayers(for: team)
        guard !players.isEmpty else { return }
        let sheet = UIAlertController(
            title: L10n.Football.Match.Live.pickPlayer,
            message: nil,
            preferredStyle: .actionSheet
        )
        for player in players {
            sheet.addAction(UIAlertAction(title: player.name, style: .default) { [weak self] _ in
                self?.viewModel.addEvent(type, team: team, player: player)
            })
        }
        sheet.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        if let pop = sheet.popoverPresentationController {
            pop.sourceView = view
            pop.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        }
        present(sheet, animated: true)
    }

    private func actionTitle(_ type: MatchEventType) -> String {
        switch type {
        case .goal: return L10n.Football.Match.Event.goal
        case .yellowCard: return L10n.Football.Match.Event.yellow
        case .redCard: return L10n.Football.Match.Event.red
        case .substitution: return L10n.Football.Match.Event.sub
        case .varReview: return L10n.Football.Match.Event.varShort
        case .penalty: return L10n.Football.Match.Event.penaltyShort
        }
    }

    private func typeTag(_ type: MatchEventType) -> Int {
        MatchEventType.allCases.firstIndex(of: type) ?? 0
    }

    private func typeFromTag(_ tag: Int) -> MatchEventType? {
        MatchEventType.allCases[safe: tag]
    }
}

extension MatchLiveViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.timelineSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? Spacing.s4 : Spacing.s8
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MatchTimelineHalfCell.reuseId,
            for: indexPath
        ) as! MatchTimelineHalfCell
        let section = viewModel.timelineSections[indexPath.section]
        cell.configure(
            section: section,
            settings: viewModel.match.settings,
            homeName: viewModel.match.settings.homeTeam,
            awayName: viewModel.match.settings.awayTeam
        )
        return cell
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
