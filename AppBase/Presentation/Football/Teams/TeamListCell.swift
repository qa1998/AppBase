//
//  TeamListCell.swift
//  AppBase
//

import SnapKit
import UIKit

final class TeamListCell: UITableViewCell {

    static let reuseId = "TeamListCell"

    var onDeleteTap: (() -> Void)?

    private let card = UIView()
    private let miniPitch = LineupMiniPitchView()
    private let titleLabel = UILabel()
    private let sizeTag = UILabel()
    private let formationTag = UILabel()
    private let playersLabel = UILabel()
    private let deleteButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        card.backgroundColor = FootballPalette.surface
        card.layer.cornerRadius = Radius.s16

        titleLabel.font = FootballPalette.title(16)
        titleLabel.textColor = FootballPalette.textPrimary

        [sizeTag, formationTag].forEach { tag in
            tag.font = FootballPalette.caption(11)
            tag.textColor = FootballPalette.textSecondary
            tag.backgroundColor = FootballPalette.surfaceElevated
            tag.layer.cornerRadius = Radius.s8
            tag.clipsToBounds = true
            tag.textAlignment = .center
        }

        playersLabel.font = FootballPalette.caption(11)
        playersLabel.textColor = FootballPalette.textSecondary

        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = FootballPalette.textSecondary
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        contentView.addSubview(card)
        card.addSubview(miniPitch)
        card.addSubview(titleLabel)
        card.addSubview(sizeTag)
        card.addSubview(formationTag)
        card.addSubview(playersLabel)
        card.addSubview(deleteButton)

        card.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 20, bottom: 6, right: 20))
        }
        miniPitch.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(Spacing.s12)
            make.width.equalTo(72)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.s12)
            make.leading.equalTo(miniPitch.snp.trailing).offset(Spacing.s12)
            make.trailing.lessThanOrEqualTo(deleteButton.snp.leading).offset(-Spacing.s8)
        }
        sizeTag.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.s8)
            make.leading.equalTo(titleLabel)
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(52)
        }
        formationTag.snp.makeConstraints { make in
            make.centerY.equalTo(sizeTag)
            make.leading.equalTo(sizeTag.snp.trailing).offset(Spacing.s6)
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(44)
        }
        playersLabel.snp.makeConstraints { make in
            make.top.equalTo(sizeTag.snp.bottom).offset(Spacing.s6)
            make.leading.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(Spacing.s12)
        }
        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Spacing.s12)
            make.centerY.equalToSuperview()
            make.size.equalTo(36)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ team: FootballTeam, showsDelete: Bool = true) {
        deleteButton.isHidden = !showsDelete
        titleLabel.text = team.name.isEmpty ? L10n.Football.Teams.unnamed : team.name
        sizeTag.text = "  \(L10n.Football.Match.Create.pitchPlayers(team.pitchSize.playerCount))  "
        formationTag.text = "  \(team.formation.name)  "
        playersLabel.text = L10n.Football.Teams.rosterCount(team.filledPitchSlots, team.assignments.count)
        miniPitch.assignments = team.assignments
        miniPitch.setNeedsDisplay()
    }

    @objc private func deleteTapped() {
        onDeleteTap?()
    }
}
