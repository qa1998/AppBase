//
//  MyLineupsViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import SnapKit
import UIKit

final class MyLineupsViewController: FootballScreenViewController<MyLineupsViewModel> {

    var onCreateLineup: (() -> Void)?
    var onOpenLineup: ((FootballLineup) -> Void)?
    var onShareLineup: ((FootballLineup) -> Void)?
    var onPremiumTap: (() -> Void)?

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let fabContainer = FootballGradientView()
    private let fabButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func setupUI() {
        super.setupUI()
        buildTable()
        buildFAB()
        layoutViews()
        refreshLocalization()
    }
    override var navSetting: NavigationSetting {
        var setting = super.navSetting
        setting.useLargeTitleView = true
        setting.title = L10n.Football.Lineups.title
        return setting
    }


    override func onBind() {
        super.onBind()
        viewModel.$lineups
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancelBag)
    }

    override func refreshLocalization() {
        super.refreshLocalization()
        tableView.reloadData()
    }

    override func refreshFootballTheme() {
        super.refreshFootballTheme()
        view.backgroundColor = FootballPalette.background
        fabButton.tintColor = FootballPalette.onAccent
        tableView.reloadData()
        fabContainer.layer.shadowColor = FootballPalette.accentRed.cgColor
    }

    private func buildTable() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.register(LineupListCell.self, forCellReuseIdentifier: LineupListCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 128
    }

    private func buildFAB() {
        fabContainer.layer.cornerRadius = 28
        fabContainer.layer.shadowColor = FootballPalette.accentRed.cgColor
        fabContainer.layer.shadowOpacity = 0.45
        fabContainer.layer.shadowRadius = 12
        fabContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        fabButton.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)), for: .normal)
        fabButton.tintColor = FootballPalette.onAccent
        fabButton.addTarget(self, action: #selector(fabTapped), for: .touchUpInside)
        fabContainer.addSubview(fabButton)
        fabButton.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func layoutViews() {
        view.addSubview(tableView)
        view.addSubview(fabContainer)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.s16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        fabContainer.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Spacing.s24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(88)
            make.size.equalTo(56)
        }

    }
    @objc private func filterTapped(_ sender: LineupFilterChipButton) {
        guard let filter = LineupListFilter(rawValue: sender.tag) else { return }
        viewModel.selectFilter(filter)
    }

    @objc private func fabTapped() {
        viewModel.createLineup()
        onCreateLineup?()
    }

    func showPremiumHint() {
        viewModel.presentSuccess(L10n.Football.Lineups.premiumHint)
    }

    @objc private func premiumTapped() {
        onPremiumTap?()
    }

    @objc private func titleTapped() {
        let sheet = UIAlertController(title: L10n.Football.Lineups.sortTitle, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: L10n.Football.Lineups.sortRecent, style: .default) { [weak self] _ in
            self?.viewModel.selectFilter(.recent)
        })
        sheet.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        present(sheet, animated: true)
    }

    private func showMoreMenu(for lineup: FootballLineup, source: UIView) {
        let sheet = UIAlertController(title: lineup.displayTitle, message: nil, preferredStyle: .actionSheet)
        let favTitle = lineup.isFavorite
            ? L10n.Football.Lineups.unfavorite
            : L10n.Football.Lineups.favorite
        sheet.addAction(UIAlertAction(title: favTitle, style: .default) { [weak self] _ in
            self?.viewModel.toggleFavorite(lineup)
        })
        sheet.addAction(UIAlertAction(title: L10n.Football.Editor.title, style: .default) { [weak self] _ in
            self?.viewModel.openLineup(lineup)
            self?.onOpenLineup?(lineup)
        })
        sheet.addAction(UIAlertAction(title: L10n.Football.Share.shareAction, style: .default) { [weak self] _ in
            self?.onShareLineup?(lineup)
        })
        sheet.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = source
            popover.sourceRect = source.bounds
        }
        present(sheet, animated: true)
    }
}

extension MyLineupsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.lineups.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: LineupListCell.reuseId,
            for: indexPath
        ) as! LineupListCell
        let lineup = viewModel.lineups[indexPath.row]
        cell.configure(with: lineup)
        cell.applyTheme()
        cell.onMoreTap = { [weak self, weak cell] in
            guard let self, let cell else { return }
            self.showMoreMenu(for: lineup, source: cell)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lineup = viewModel.lineups[indexPath.row]
        viewModel.openLineup(lineup)
        onOpenLineup?(lineup)
    }
}
