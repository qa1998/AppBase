//
//  FootballMatchesViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import SnapKit
import UIKit

final class FootballMatchesViewController: FootballScreenViewController<FootballMatchesViewModel> {

    var onCreateMatch: (() -> Void)?
    var onOpenMatch: ((FootballMatch) -> Void)?


    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    private let fabButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override var navSetting: NavigationSetting {
        var setting = super.navSetting
        setting.useLargeTitleView = true
        setting.title = L10n.Football.Matches.title
        return setting
    }

    override func setupUI() {
        super.setupUI()

        emptyLabel.font = FootballPalette.body()
        emptyLabel.textColor = FootballPalette.textSecondary
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.text = L10n.Football.Matches.empty

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MatchListCell.self, forCellReuseIdentifier: MatchListCell.reuseId)

        fabButton.backgroundColor = FootballPalette.accentRed
        fabButton.tintColor = .white
        fabButton.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)), for: .normal)
        fabButton.layer.cornerRadius = 28
        fabButton.layer.shadowColor = FootballPalette.accentRed.cgColor
        fabButton.layer.shadowOpacity = 0.45
        fabButton.layer.shadowRadius = 8
        fabButton.addTarget(self, action: #selector(fabTapped), for: .touchUpInside)


        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(fabButton)

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.s16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(tableView)
            make.leading.trailing.equalToSuperview().inset(Spacing.s32)
        }
        fabButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Spacing.s24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Spacing.s24)
            make.size.equalTo(56)
        }
    }

    override func onBind() {
        super.onBind()
        viewModel.$matches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matches in
                self?.tableView.reloadData()
                self?.emptyLabel.isHidden = !matches.isEmpty
            }
            .store(in: &cancelBag)
    }

    @objc private func fabTapped() {
        onCreateMatch?()
    }
}

extension FootballMatchesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.matches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MatchListCell.reuseId, for: indexPath) as! MatchListCell
        cell.configure(match: viewModel.matches[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onOpenMatch?(viewModel.matches[indexPath.row])
    }
}
