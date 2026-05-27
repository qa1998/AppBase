//
//  MatchLiveViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import JXSegmentedView
import SnapKit
import UIKit

final class MatchLiveViewController: TIOPagerViewController<MatchLiveViewModel> {

    private enum LiveTab: Int {
        case events = 0
        case lineups = 1
    }

    private let listHost = UIView()
    private let expandedHeaderWrap = UIView()
    private let scoreboard = MatchLiveScoreboardView()
    private let phaseActionButton = UIButton(type: .system)
    private let finishBar = MatchLiveFinishBarView()
    private let segmentWrap = UIView()
    private let navMinHeader = MatchLiveMinHeaderView()
    private let filtersScroll = UIScrollView()
    private let filtersStack = UIStackView()
    private var filterChips: [MatchEventFilterChip] = []

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let lineupsView = MatchLiveLineupsView()
    private let lineupsScroll = UIScrollView()

    private var segmentTopConstraint: Constraint?
    private var filtersTopConstraint: Constraint?
    private var filtersHeightConstraint: Constraint?
    private var filtersStackHeightConstraint: Constraint?
    private var lineupsWidthConstraint: Constraint?
    private var lineupsHeightConstraint: Constraint?
    private var expandedHeaderHeight: CGFloat = 220
    private var timelineEventCount = 0
    private var didCaptureInitialTimeline = false
    private var didSetInitialScrollInset = false

    private lazy var eventsList = MatchLiveEventsPagerList(tableView: tableView)
    private lazy var lineupsList = MatchLiveLineupsPagerList(scrollView: lineupsScroll)

    override var usesDefaultPagerLayout: Bool { false }

    override var shimmerContentView: UIView { listHost }

    override var navSetting: NavigationSetting {
        var setting = super.navSetting
        setting.title = nil
        return setting
    }

    override var pagerTitles: [String] {
        [
            L10n.Football.Match.Live.Tab.events,
            L10n.Football.Match.Live.Tab.lineups
        ]
    }

    override var pagerStyle: TIOPagerStyle {
        var style = TIOPagerStyle.default
        style.barHeight = 44
        style.contentEdgeInsetLeft = Spacing.s16
        style.contentEdgeInsetRight = Spacing.s16
        style.itemSpacing = 24
        style.isItemSpacingAverageEnabled = false
        style.titleFont = FootballPalette.body(15)
        style.selectedTitleFont = FootballPalette.title(15)
        style.titleColor = FootballPalette.textSecondary
        style.selectedTitleColor = FootballPalette.textPrimary
        style.indicatorColor = FootballPalette.textPrimary
        style.indicatorLineHeight = 2
        style.barBackgroundColor = FootballPalette.background
        style.contentBackgroundColor = FootballPalette.background
        return style
    }

    override func makePage(at index: Int) -> JXSegmentedListContainerViewListDelegate {
        if index == LiveTab.events.rawValue {
            return eventsList
        }
        return lineupsList
    }

    override func pagerDidSelect(index: Int) {
        setFiltersVisible(viewModel.showQuickActions)
        if index == LiveTab.lineups.rawValue {
            reloadLineups()
            relayoutLineupsPitchIfNeeded()
        }
        updateListContentInsets()
        syncChromeToActiveList()
    }

    override func setupUI() {
        buildChrome()
        installPager(segmentContainer: segmentWrap, listContainer: listHost)
        buildFilters()
        buildTable()
        buildLineupsScroll()
        super.setupUI()
        setupNavigationMinHeader()
        refreshScoreboard()
        refreshNavigationMinHeader()
        refreshPhaseActionButton()
        refreshFinishBar()
        setFiltersVisible(viewModel.showQuickActions)
        DispatchQueue.main.async { [weak self] in
            self?.remeasureExpandedHeader()
        }
    }

    override func refreshLocalization() {
        super.refreshLocalization()
        refreshScoreboard()
        refreshNavigationMinHeader()
        rebuildFilterChips()
        refreshPhaseActionButton()
        refreshFinishBar()
        tableView.reloadData()
        reloadLineups()
        remeasureExpandedHeader()
    }

    override func applyScreenTheme(_ colors: ThemeColors) {
        super.applyScreenTheme(colors)
        view.backgroundColor = FootballPalette.background
        segmentWrap.backgroundColor = FootballPalette.background
        expandedHeaderWrap.backgroundColor = FootballPalette.background
        scoreboard.applyTheme()
        navMinHeader.applyTheme()
        finishBar.applyTheme()
        applyPhaseActionTheme()
        filterChips.forEach { $0.applyTheme() }
        lineupsView.applyTheme()
        tableView.reloadData()
    }

    override func onBind() {
        super.onBind()
        viewModel.$clockText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshScoreboard()
                self?.refreshNavigationMinHeader()
            }
            .store(in: &cancelBag)
        viewModel.$phaseTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshScoreboard()
                self?.refreshNavigationMinHeader()
            }
            .store(in: &cancelBag)
        viewModel.$primaryButtonTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.refreshPhaseActionButton() }
            .store(in: &cancelBag)
        viewModel.$showQuickActions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                self?.setFiltersVisible(show)
                self?.refreshFinishBar()
                self?.updateListContentInsets()
            }
            .store(in: &cancelBag)
        viewModel.$timelineSections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                guard let self else { return }
                let count = sections.reduce(0) { $0 + $1.rows.count }
                let shouldScrollToNewEvent: Bool
                if !self.didCaptureInitialTimeline {
                    self.didCaptureInitialTimeline = true
                    self.timelineEventCount = count
                    shouldScrollToNewEvent = false
                } else {
                    shouldScrollToNewEvent = count > self.timelineEventCount
                    self.timelineEventCount = count
                }
                self.tableView.reloadData()
                self.reloadLineups()
                if shouldScrollToNewEvent, self.selectedPageIndex == LiveTab.events.rawValue {
                    self.scrollTimelineToBottom()
                }
            }
            .store(in: &cancelBag)
        Publishers.CombineLatest(viewModel.$match, viewModel.$timelineSections)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.refreshScoreboard()
                self?.refreshNavigationMinHeader()
                self?.reloadLineups()
                self?.refreshFinishBar()
                self?.remeasureExpandedHeader()
            }
            .store(in: &cancelBag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateNavigationMinHeaderLayout()
        remeasureExpandedHeader()
        if view.bounds.width > 0 {
            updateLineupsContentSize()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            viewModel.persistState()
        }
    }

    // MARK: - Chrome

    private func buildChrome() {
        view.backgroundColor = FootballPalette.background

        phaseActionButton.titleLabel?.font = FootballPalette.title(15)
        phaseActionButton.layer.cornerRadius = Radius.s12
        phaseActionButton.addTarget(self, action: #selector(phaseActionTapped), for: .touchUpInside)

        finishBar.onTap = { [weak self] in
            self?.finishMatchTapped()
        }

        let expandedStack = UIStackView(arrangedSubviews: [scoreboard, phaseActionButton, finishBar])
        expandedStack.axis = .vertical
        expandedStack.spacing = Spacing.s12
        expandedStack.alignment = .fill
        phaseActionButton.snp.makeConstraints { $0.height.equalTo(46) }

        expandedHeaderWrap.addSubview(expandedStack)
        expandedStack.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Spacing.s8)
            make.leading.trailing.equalToSuperview().inset(Spacing.s16)
            make.bottom.equalToSuperview().inset(Spacing.s4)
        }

        view.addSubview(listHost)
        view.addSubview(expandedHeaderWrap)
        view.addSubview(filtersScroll)
        view.addSubview(segmentWrap)

        listHost.snp.makeConstraints { $0.edges.equalToSuperview() }

        expandedHeaderWrap.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }

        segmentWrap.snp.makeConstraints { make in
            segmentTopConstraint = make.top.equalTo(view.safeAreaLayoutGuide).offset(expandedHeaderHeight).constraint
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(pagerStyle.barHeight)
        }

        filtersScroll.snp.makeConstraints { make in
            filtersTopConstraint = make.top.equalTo(segmentWrap.snp.bottom).constraint
            make.leading.trailing.equalToSuperview()
            filtersHeightConstraint = make.height.equalTo(44).constraint
        }

        segmentWrap.layer.zPosition = 9
        filtersScroll.layer.zPosition = 8
        expandedHeaderWrap.layer.zPosition = 7
    }

    private func buildFilters() {
        filtersStack.axis = .horizontal
        filtersStack.spacing = Spacing.s8
        filtersStack.alignment = .center
        filtersScroll.showsHorizontalScrollIndicator = false
        filtersScroll.backgroundColor = FootballPalette.background
        filtersScroll.addSubview(filtersStack)
        filtersStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: Spacing.s16, bottom: 0, right: Spacing.s16))
            make.top.bottom.equalToSuperview()
            filtersStackHeightConstraint = make.height.equalTo(44).constraint
        }
        rebuildFilterChips()
    }

    private func buildTable() {
        tableView.backgroundColor = FootballPalette.background
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = true
        tableView.estimatedRowHeight = 280
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MatchTimelineHalfCell.self, forCellReuseIdentifier: MatchTimelineHalfCell.reuseId)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }

    private func buildLineupsScroll() {
        lineupsScroll.showsVerticalScrollIndicator = true
        lineupsScroll.alwaysBounceVertical = true
        lineupsScroll.backgroundColor = FootballPalette.background
        lineupsScroll.delegate = self
        lineupsScroll.addSubview(lineupsView)
        let initialWidth = max(view.bounds.width - Spacing.s32, 280)
        lineupsView.snp.makeConstraints { make in
            make.top.equalTo(lineupsScroll.contentLayoutGuide).offset(Spacing.s16)
            make.leading.equalTo(lineupsScroll.contentLayoutGuide).offset(Spacing.s16)
            make.bottom.equalTo(lineupsScroll.contentLayoutGuide).offset(-Spacing.s16)
            lineupsWidthConstraint = make.width.equalTo(initialWidth).constraint
            lineupsHeightConstraint = make.height.equalTo(1).constraint
        }
    }

    // MARK: - Scroll / sticky

    private var filtersBarHeight: CGFloat {
        (filtersScroll.isHidden ? 0 : 44)
    }

    private var chromeInsetTop: CGFloat {
        expandedHeaderHeight + pagerStyle.barHeight + filtersBarHeight
    }

    private func remeasureExpandedHeader() {
        expandedHeaderWrap.setNeedsLayout()
        expandedHeaderWrap.layoutIfNeeded()
        let width = view.bounds.width
        guard width > 0 else { return }
        let measured = expandedHeaderWrap.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        guard measured > 0, abs(measured - expandedHeaderHeight) > 0.5 else {
            updateListContentInsets()
            return
        }
        expandedHeaderHeight = measured
        segmentTopConstraint?.update(offset: expandedHeaderHeight)
        updateListContentInsets()
        syncChromeToActiveList()
    }

    private func updateListContentInsets() {
        let inset = chromeInsetTop
        let indicator = inset
        tableView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: Spacing.s24, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: indicator, left: 0, bottom: 0, right: 0)

        lineupsScroll.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: Spacing.s24, right: 0)
        lineupsScroll.scrollIndicatorInsets = UIEdgeInsets(top: indicator, left: 0, bottom: 0, right: 0)
        updateLineupsContentSize()

        if !didSetInitialScrollInset {
            didSetInitialScrollInset = true
            tableView.contentOffset = CGPoint(x: 0, y: -inset)
            lineupsScroll.contentOffset = CGPoint(x: 0, y: -inset)
        }
    }

    private func updateLineupsContentSize() {
        guard lineupsView.superview === lineupsScroll else { return }
        let contentWidth = view.bounds.width - Spacing.s32
        guard contentWidth > 0 else { return }
        let contentH = lineupsView.preferredHeight(forWidth: contentWidth)
        lineupsWidthConstraint?.update(offset: contentWidth)
        lineupsHeightConstraint?.update(offset: contentH)
        lineupsView.setNeedsLayout()
        lineupsView.layoutIfNeeded()
        relayoutLineupsPitchIfNeeded()
    }

    private func relayoutLineupsPitchIfNeeded() {
        lineupsView.relayoutPitchTokens()
    }

    private func activeScrollView() -> UIScrollView? {
        selectedPageIndex == LiveTab.events.rawValue ? tableView : lineupsScroll
    }

    private func syncChromeToActiveList() {
        guard let scroll = activeScrollView() else { return }
        handleListScroll(scroll)
    }

    private func handleListScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        let collapse = max(expandedHeaderHeight, 1)

        expandedHeaderWrap.transform = CGAffineTransform(
            translationX: 0,
            y: -min(y, collapse)
        )

        let segmentOffset = max(0, expandedHeaderHeight - y)
        segmentTopConstraint?.update(offset: segmentOffset)

        let navProgress = min(1, max(0, (y - (expandedHeaderHeight - 40)) / 40))
        navMinHeader.alpha = navProgress
        navigationItem.titleView = navProgress > 0.01 ? navMinHeader : nil

        if selectedPageIndex == LiveTab.events.rawValue, !filtersScroll.isHidden {
            filtersTopConstraint?.update(offset: 0)
        }
    }

    private func setupNavigationMinHeader() {
        navMinHeader.placement = .navigationBar
        navMinHeader.alpha = 0
        navigationItem.titleView = nil
        updateNavigationMinHeaderLayout()
    }

    private func updateNavigationMinHeaderLayout() {
        let width = max(160, view.bounds.width - 108)
        navMinHeader.frame = CGRect(x: 0, y: 0, width: width, height: 36)
        navMinHeader.setNeedsLayout()
        navMinHeader.layoutIfNeeded()
    }

    private func refreshNavigationMinHeader() {
        let settings = viewModel.match.settings
        navMinHeader.configure(
            homeName: settings.homeTeam,
            awayName: settings.awayTeam,
            scoreText: viewModel.match.scoreLine
        )
        navMinHeader.applyTheme()
    }

    // MARK: - Data refresh

    private func rebuildFilterChips() {
        filterChips.forEach {
            filtersStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        filterChips.removeAll()

        MatchEventType.allCases.forEach { type in
            let chip = MatchEventFilterChip(type: type, title: quickActionTitle(type))
            chip.addTarget(self, action: #selector(quickActionTapped(_:)), for: .touchUpInside)
            filtersStack.addArrangedSubview(chip)
            filterChips.append(chip)
        }
    }

    private func setFiltersVisible(_ visible: Bool) {
        let onEvents = selectedPageIndex == LiveTab.events.rawValue
        let show = visible && onEvents
        filtersScroll.isHidden = !show
        filtersStack.isHidden = !show
        filtersHeightConstraint?.update(offset: show ? 44 : 0)
        if show {
            filtersStackHeightConstraint?.activate()
        } else {
            filtersStackHeightConstraint?.deactivate()
        }
        updateListContentInsets()
        syncChromeToActiveList()
    }

    private func reloadLineups() {
        lineupsView.configure(settings: viewModel.match.settings) { [weak self] playerId, side in
            guard let self else { return MatchLivePlayerStatus() }
            return self.viewModel.playerStatus(playerId: playerId, team: side)
        }
        lineupsView.applyTheme()
        updateLineupsContentSize()
    }

    private func refreshFinishBar() {
        let show = viewModel.showFinishMatchButton
        finishBar.isHidden = !show
        finishBar.setTitle(L10n.Football.Match.Live.finishMatch)
        finishBar.applyTheme()
        remeasureExpandedHeader()
    }

    private func refreshPhaseActionButton() {
        let title = viewModel.primaryButtonTitle
        phaseActionButton.isHidden = title == nil
        phaseActionButton.setTitle(title, for: .normal)
        applyPhaseActionTheme()
        remeasureExpandedHeader()
    }

    private func applyPhaseActionTheme() {
        phaseActionButton.backgroundColor = FootballPalette.accentGreen
        phaseActionButton.setTitleColor(FootballPalette.onAccent, for: .normal)
    }

    private func refreshScoreboard() {
        let m = viewModel.match
        let settings = m.settings
        let finished = m.phase == .finished
        scoreboard.configure(
            homeName: settings.homeTeam,
            awayName: settings.awayTeam,
            homeCount: settings.homeRoster.filledPitchSlots,
            awayCount: settings.awayRoster.filledPitchSlots,
            scoreText: m.scoreLine,
            phaseText: viewModel.phaseTitle,
            clockText: viewModel.clockText,
            isFinished: finished
        )
        scoreboard.applyTheme()
    }

    private func scrollTimelineToBottom() {
        guard selectedPageIndex == LiveTab.events.rawValue else { return }
        let sections = viewModel.timelineSections.count
        guard sections > 0 else { return }
        tableView.layoutIfNeeded()
        let indexPath = IndexPath(row: 0, section: sections - 1)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    // MARK: - Actions

    @objc private func phaseActionTapped() {
        viewModel.performPrimaryAction()
    }

    @objc private func quickActionTapped(_ sender: MatchEventFilterChip) {
        guard let type = sender.eventType else { return }
        pickTeam(for: type, sourceView: sender)
    }

    @objc private func finishMatchTapped() {
        let alert = UIAlertController(
            title: L10n.Football.Match.Live.finishMatch,
            message: L10n.Football.Match.Live.finishConfirm,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.Football.Match.Live.finishMatch, style: .destructive) { [weak self] _ in
            self?.viewModel.endMatchNow()
        })
        present(alert, animated: true)
    }

    private func pickTeam(for type: MatchEventType, sourceView: UIView) {
        let sheet = UIAlertController(title: quickActionTitle(type), message: nil, preferredStyle: .actionSheet)
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
            pop.sourceView = sourceView
            pop.sourceRect = sourceView.bounds
        }
        present(sheet, animated: true)
    }

    private func pickPlayer(for type: MatchEventType, team: MatchTeamSide) {
        let players = viewModel.selectablePlayers(for: team)
        guard !players.isEmpty else {
            viewModel.presentError(message: L10n.Football.Match.Live.noSelectablePlayers)
            return
        }
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

    private func quickActionTitle(_ type: MatchEventType) -> String {
        switch type {
        case .goal: return L10n.Football.Match.Event.goal
        case .yellowCard: return L10n.Football.Match.Event.yellow
        case .redCard: return L10n.Football.Match.Event.red
        case .substitution: return L10n.Football.Match.Event.sub
        case .varReview: return L10n.Football.Match.Event.varShort
        case .penalty: return L10n.Football.Match.Event.penaltyShort
        }
    }
}

// MARK: - Pager lists

private final class MatchLiveEventsPagerList: UIView, JXSegmentedListContainerViewListDelegate {

    private let tableView: UITableView
    private var didInstallConstraints = false

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        installTableLayoutIfNeeded()
    }

    func listView() -> UIView { self }

    private func installTableLayoutIfNeeded() {
        guard superview != nil, !didInstallConstraints else { return }
        if tableView.superview != self {
            tableView.removeFromSuperview()
            addSubview(tableView)
        }
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        didInstallConstraints = true
    }
}

private final class MatchLiveLineupsPagerList: UIView, JXSegmentedListContainerViewListDelegate {

    private let scrollView: UIScrollView
    private var didInstallConstraints = false

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        installScrollLayoutIfNeeded()
    }

    func listView() -> UIView { self }

    private func installScrollLayoutIfNeeded() {
        guard superview != nil, !didInstallConstraints else { return }
        if scrollView.superview != self {
            scrollView.removeFromSuperview()
            addSubview(scrollView)
        }
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        didInstallConstraints = true
    }
}

// MARK: - Table

extension MatchLiveViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.timelineSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? Spacing.s4 : Spacing.s12
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

// MARK: - Scroll

extension MatchLiveViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === tableView || scrollView === lineupsScroll else { return }
        handleListScroll(scrollView)
    }
}
