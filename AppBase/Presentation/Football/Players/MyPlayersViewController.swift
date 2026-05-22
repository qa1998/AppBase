//
//  MyPlayersViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import SnapKit
import UIKit

final class MyPlayersViewController: FootballScreenViewController<MyPlayersViewModel> {

    var onCreatePlayer: (() -> Void)?
    var onOpenPlayer: ((FootballPlayer) -> Void)?

    private let titleLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    private let fabContainer = FootballGradientView()
    private let fabButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        let isPushed = (navigationController?.viewControllers.count ?? 0) > 1
        
        titleLabel.isHidden = isPushed
        if isPushed {
            title = L10n.Football.Players.libraryTitle
            tableView.snp.remakeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.s8)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
    }

    override func setupUI() {
        super.setupUI()
        titleLabel.font = FootballPalette.headline(28)
        titleLabel.textColor = FootballPalette.textPrimary
        titleLabel.text = L10n.Football.Players.libraryTitle

        emptyLabel.font = FootballPalette.caption()
        emptyLabel.textColor = FootballPalette.textSecondary
        emptyLabel.text = L10n.Football.Players.libraryEmpty
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.isHidden = true

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlayerCardCell.self, forCellReuseIdentifier: PlayerCardCell.reuseId)

        fabButton.setImage(
            UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)),
            for: .normal
        )
        fabButton.tintColor = .white
        fabButton.addTarget(self, action: #selector(fabTapped), for: .touchUpInside)
        fabContainer.layer.cornerRadius = 30
        fabContainer.layer.shadowColor = FootballPalette.accentRed.cgColor
        fabContainer.layer.shadowOpacity = 0.35
        fabContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        fabContainer.layer.shadowRadius = 10
        fabContainer.addSubview(fabButton)
        fabButton.snp.makeConstraints { $0.edges.equalToSuperview().inset(14) }

        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(fabContainer)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.s16)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.s16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(tableView)
            make.leading.trailing.equalToSuperview().inset(Spacing.s32)
        }
        fabContainer.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Spacing.s24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Spacing.s24)
            make.size.equalTo(60)
        }
    }

    override func onBind() {
        super.onBind()
        viewModel.$players
            .receive(on: DispatchQueue.main)
            .sink { [weak self] players in
                self?.tableView.reloadData()
                self?.emptyLabel.isHidden = !players.isEmpty
            }
            .store(in: &cancelBag)
    }

    @objc private func fabTapped() {
        viewModel.createPlayer()
        onCreatePlayer?()
    }
}

extension MyPlayersViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.players.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlayerCardCell.reuseId, for: indexPath) as! PlayerCardCell
        cell.configure(player: viewModel.players[indexPath.row], showsRating: false)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let player = viewModel.players[indexPath.row]
        viewModel.openPlayer(player)
        onOpenPlayer?(player)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let player = viewModel.players[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: L10n.Football.Players.deleteConfirm) { [weak self] _, _, done in
            self?.viewModel.deletePlayer(player)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
