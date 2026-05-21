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
    }

    override func onBind() {
        super.onBind()
        viewModel.$players
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &cancelBag)
    }

    private func buildFilters() {
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
}

extension PlayerPickerViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.players.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: PlayerCardCell.reuseId,
            for: indexPath
        ) as! PlayerCardCell
        cell.configure(player: viewModel.players[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.select(viewModel.players[indexPath.row])
        onPlayerSelected?()
        navigationController?.popViewController(animated: true)
    }
}

extension PlayerPickerViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
    }
}

private final class PlayerCardCell: UITableViewCell {

    static let reuseId = "PlayerCardCell"
    private let card = FootballGlassView()
    private let avatarLabel = UILabel()
    private let nameLabel = UILabel()
    private let metaLabel = UILabel()
    private let ratingLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(card)
        card.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
        }
        [avatarLabel, nameLabel, metaLabel, ratingLabel].forEach { card.addSubview($0) }
        avatarLabel.font = FootballPalette.title(14)
        avatarLabel.textColor = FootballPalette.textPrimary
        avatarLabel.textAlignment = .center
        avatarLabel.backgroundColor = FootballPalette.surfaceElevated
        avatarLabel.layer.cornerRadius = 22
        avatarLabel.clipsToBounds = true
        nameLabel.font = FootballPalette.title(15)
        nameLabel.textColor = FootballPalette.textPrimary
        metaLabel.font = FootballPalette.caption()
        metaLabel.textColor = FootballPalette.textSecondary
        ratingLabel.font = FootballPalette.headline(18)
        ratingLabel.textColor = FootballPalette.accentGreen
        avatarLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview().inset(Spacing.s12)
            make.size.equalTo(44)
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarLabel.snp.trailing).offset(Spacing.s12)
            make.top.equalToSuperview().offset(Spacing.s14)
        }
        metaLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
        }
        ratingLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Spacing.s16)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(player: FootballPlayer) {
        avatarLabel.text = player.initials
        nameLabel.text = player.name
        metaLabel.text = "\(player.club) · \(player.nation) · \(player.position.label)"
        ratingLabel.text = "\(player.rating)"
    }
}
