//
//  MyTeamsViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import SnapKit
import UIKit

final class MyTeamsViewController: FootballScreenViewController<MyTeamsViewModel> {

    var onCreateTeam: (() -> Void)?
    var onOpenTeam: ((FootballTeam) -> Void)?

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    private let fabContainer = FootballGradientView()
    private let fabButton = UIButton(type: .system)
    
    override var navSetting: NavigationSetting {
        var setting = super.navSetting
        setting.useLargeTitleView = true
        setting.title = L10n.Football.Teams.title
        return setting
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func setupUI() {
        super.setupUI()

        emptyLabel.font = FootballPalette.caption()
        emptyLabel.textColor = FootballPalette.textSecondary
        emptyLabel.text = L10n.Football.Teams.empty
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.isHidden = true

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TeamListCell.self, forCellReuseIdentifier: TeamListCell.reuseId)

        fabButton.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)), for: .normal)
        fabButton.tintColor = .white
        fabButton.addTarget(self, action: #selector(fabTapped), for: .touchUpInside)
        fabContainer.layer.cornerRadius = 30
        fabContainer.layer.shadowColor = FootballPalette.accentRed.cgColor
        fabContainer.layer.shadowOpacity = 0.35
        fabContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        fabContainer.layer.shadowRadius = 10
        fabContainer.addSubview(fabButton)
        fabButton.snp.makeConstraints { $0.edges.equalToSuperview().inset(14) }

        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(fabContainer)


        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.s16)
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
        viewModel.$teams
            .receive(on: DispatchQueue.main)
            .sink { [weak self] teams in
                self?.tableView.reloadData()
                self?.emptyLabel.isHidden = !teams.isEmpty
            }
            .store(in: &cancelBag)
    }

    @objc private func fabTapped() {
        viewModel.createTeam()
        onCreateTeam?()
    }
}

extension MyTeamsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.teams.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TeamListCell.reuseId, for: indexPath) as! TeamListCell
        let team = viewModel.teams[indexPath.row]
        cell.configure(team)
        cell.onDeleteTap = { [weak self] in
            self?.confirmDelete(team)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let team = viewModel.teams[indexPath.row]
        viewModel.openTeam(team)
        onOpenTeam?(team)
    }

    private func confirmDelete(_ team: FootballTeam) {
        let sheet = UIAlertController(
            title: L10n.Football.Teams.deleteTitle,
            message: team.name,
            preferredStyle: .alert
        )
        sheet.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        sheet.addAction(UIAlertAction(title: L10n.Football.Teams.deleteConfirm, style: .destructive) { [weak self] _ in
            self?.viewModel.deleteTeam(team)
        })
        present(sheet, animated: true)
    }
}
