//
//  TeamPickerViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import SnapKit
import UIKit

final class TeamPickerViewController: FootballScreenViewController<TeamPickerViewModel> {

    var onSelect: ((FootballTeam) -> Void)?

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
    }

    override func setupUI() {
        super.setupUI()
        title = L10n.Football.Teams.pickTitle

        emptyLabel.font = FootballPalette.caption()
        emptyLabel.textColor = FootballPalette.textSecondary
        emptyLabel.text = L10n.Football.Teams.empty
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0

        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TeamListCell.self, forCellReuseIdentifier: TeamListCell.reuseId)

        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Spacing.s32)
        }
    }

    override func onBind() {
        super.onBind()
        viewModel.$teams
            .receive(on: DispatchQueue.main)
            .sink { [weak self] teams in
                self?.tableView.reloadData()
                self?.emptyLabel.isHidden = !teams.isEmpty
            }
            .store(in: &cancelBag)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

extension TeamPickerViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.teams.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TeamListCell.reuseId, for: indexPath) as! TeamListCell
        cell.configure(viewModel.teams[indexPath.row], showsDelete: false)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = viewModel.teams[indexPath.row]
        onSelect?(team)
        dismiss(animated: true)
    }
}
