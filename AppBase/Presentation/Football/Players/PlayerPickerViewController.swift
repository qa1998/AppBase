//
//  PlayerPickerViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import SnapKit
import UIKit

final class PlayerPickerViewController: FootballScreenViewController<PlayerPickerViewModel> {

    var onPlayerSelected: (() -> Void)?
    var onCreatePlayer: (() -> Void)?

    private enum Section {
        case create
        case clearPosition
        case players
    }

    private var sections: [Section] {
        var list: [Section] = [.create]
        if viewModel.canClearTargetPosition {
            list.append(.clearPosition)
        }
        list.append(.players)
        return list
    }

    private let searchBar = UISearchBar()
    private let filterScroll = UIScrollView()
    private let filterStack = UIStackView()
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func setupUI() {
        super.setupUI()
        refreshLocalization()

        searchBar.searchBarStyle = .minimal
        searchBar.barTintColor = FootballPalette.surface
        searchBar.searchTextField.backgroundColor = FootballPalette.surfaceElevated
        searchBar.searchTextField.textColor = FootballPalette.textPrimary
        searchBar.delegate = self

        filterStack.axis = .horizontal
        filterStack.spacing = Spacing.s8
        filterScroll.showsHorizontalScrollIndicator = false
        filterScroll.addSubview(filterStack)
        filterStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        buildFilters()

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(PlayerCardCell.self, forCellReuseIdentifier: PlayerCardCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 88
        tableView.register(
            PlayerPickerCreateCell.self,
            forCellReuseIdentifier: PlayerPickerCreateCell.reuseId
        )
        tableView.register(
            PlayerPickerClearCell.self,
            forCellReuseIdentifier: PlayerPickerClearCell.reuseId
        )

        let addItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(createPlayerTapped)
        )
        addItem.accessibilityLabel = L10n.Football.Players.create
        navigationItem.rightBarButtonItem = addItem

        view.addSubview(searchBar)
        view.addSubview(filterScroll)
        view.addSubview(tableView)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        filterScroll.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(filterScroll.snp.bottom).offset(Spacing.s8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    override func refreshLocalization() {
        title = L10n.Football.Players.title
        searchBar.placeholder = L10n.Football.Players.search
        navigationItem.rightBarButtonItem?.accessibilityLabel = L10n.Football.Players.create
        rebuildFilters()
        tableView.reloadData()
    }

    override func refreshFootballTheme() {
        super.refreshFootballTheme()
        tableView.reloadData()
    }

    override func onBind() {
        super.onBind()
        viewModel.$players
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &cancelBag)

        viewModel.$squadRevision
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &cancelBag)
    }

    private func buildFilters() {
        rebuildFilters()
    }

    private func rebuildFilters() {
        filterStack.arrangedSubviews.forEach {
            filterStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        let filters: [(String, FootballPosition?)] = [
            (L10n.Football.Players.Filter.position, nil),
            (FootballPosition.gk.label, .gk),
            (FootballPosition.def.label, .def),
            (FootballPosition.mid.label, .mid),
            (FootballPosition.fwd.label, .fwd),
        ]
        for (title, position) in filters {
            let button = FootballNeonButton(title: title, style: .secondary)
            button.addAction(UIAction { [weak self] _ in
                self?.viewModel.positionFilter = position
            }, for: .touchUpInside)
            filterStack.addArrangedSubview(button)
        }
    }

    @objc private func createPlayerTapped() {
        onCreatePlayer?()
    }

    func finishWithCreatedPlayer(_ player: FootballPlayer) {
        viewModel.select(player)
        onPlayerSelected?()
        navigationController?.popViewController(animated: true)
    }
}

extension PlayerPickerViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .create, .clearPosition: return 1
        case .players: return viewModel.players.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section] {
        case .create, .clearPosition:
            return 64
        case .players:
            return 88
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .create:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PlayerPickerCreateCell.reuseId,
                for: indexPath
            ) as! PlayerPickerCreateCell
            cell.applyTheme()
            return cell
        case .clearPosition:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PlayerPickerClearCell.reuseId,
                for: indexPath
            ) as! PlayerPickerClearCell
            cell.applyTheme()
            return cell
        case .players:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PlayerCardCell.reuseId,
                for: indexPath
            ) as! PlayerCardCell
            let player = viewModel.players[indexPath.row]
            cell.configure(
                player: player,
                showsRating: true,
                highlight: viewModel.highlight(for: player)
            )
            cell.applyTheme()
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section] {
        case .create:
            onCreatePlayer?()
        case .clearPosition:
            viewModel.clearTargetPosition()
            onPlayerSelected?()
            navigationController?.popViewController(animated: true)
        case .players:
            let player = viewModel.players[indexPath.row]
            if viewModel.highlight(for: player) == .currentTarget {
                viewModel.clearTargetPosition()
            } else {
                viewModel.select(player)
            }
            onPlayerSelected?()
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - Action rows

private final class PlayerPickerClearCell: UITableViewCell {

    static let reuseId = "PlayerPickerClearCell"

    private let card = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .default

        card.layer.cornerRadius = Radius.s12
        card.layer.borderWidth = 1

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        iconView.image = UIImage(systemName: "minus.circle.fill", withConfiguration: symbolConfig)
        iconView.contentMode = .scaleAspectFit

        titleLabel.font = FootballPalette.title(15)

        contentView.addSubview(card)
        card.addSubview(iconView)
        card.addSubview(titleLabel)

        card.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
            make.height.equalTo(56)
        }
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.s16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(Spacing.s12)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().inset(Spacing.s16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyTheme() {
        card.backgroundColor = FootballPalette.surface
        titleLabel.text = L10n.Football.Players.Picker.clearPosition
        titleLabel.textColor = FootballPalette.accentRed
        iconView.tintColor = FootballPalette.accentRed
        card.layer.borderColor = FootballPalette.accentRed.withAlphaComponent(0.45).cgColor
    }
}

private final class PlayerPickerCreateCell: UITableViewCell {

    static let reuseId = "PlayerPickerCreateCell"

    private let card = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .default

        card.layer.cornerRadius = Radius.s12
        card.layer.borderWidth = 1
        card.layer.borderColor = FootballPalette.accentGreen.withAlphaComponent(0.45).cgColor

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        iconView.image = UIImage(systemName: "plus.circle.fill", withConfiguration: symbolConfig)
        iconView.tintColor = FootballPalette.accentGreen
        iconView.contentMode = .scaleAspectFit

        titleLabel.font = FootballPalette.title(15)
        titleLabel.textColor = FootballPalette.accentGreen
        titleLabel.text = L10n.Football.Players.create

        contentView.addSubview(card)
        card.addSubview(iconView)
        card.addSubview(titleLabel)

        card.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
            make.height.equalTo(56)
        }
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.s16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(Spacing.s12)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().inset(Spacing.s16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyTheme() {
        card.backgroundColor = FootballPalette.surface
        titleLabel.text = L10n.Football.Players.create
        iconView.tintColor = FootballPalette.accentGreen
        card.layer.borderColor = FootballPalette.accentGreen.withAlphaComponent(0.45).cgColor
    }
}

extension PlayerPickerViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
    }
}
