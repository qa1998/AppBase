//
//  PlayerCardCell.swift
//  AppBase
//

import SnapKit
import UIKit

final class PlayerCardCell: UITableViewCell {

    static let reuseId = "PlayerCardCell"

    private let card = FootballGlassView()
    private let avatarView = UIImageView()
    private let avatarLabel = UILabel()
    private let nameLabel = UILabel()
    private let metaLabel = UILabel()
    private let ratingLabel = UILabel()
    private var highlight: PlayerPickerHighlight = .none

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(card)
        card.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
        }
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        avatarView.layer.cornerRadius = 22
        avatarView.backgroundColor = FootballPalette.surfaceElevated
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
        [avatarView, avatarLabel, nameLabel, metaLabel, ratingLabel].forEach { card.addSubview($0) }
        avatarView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview().inset(Spacing.s12)
            make.size.equalTo(44)
        }
        avatarLabel.snp.makeConstraints { $0.edges.equalTo(avatarView) }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(Spacing.s12)
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

    func configure(
        player: FootballPlayer,
        showsRating: Bool = true,
        highlight: PlayerPickerHighlight = .none
    ) {
        self.highlight = highlight
        nameLabel.text = player.name
        if let image = player.avatarImage {
            avatarView.image = image
            avatarView.isHidden = false
            avatarLabel.isHidden = true
        } else {
            avatarView.image = nil
            avatarView.isHidden = true
            avatarLabel.isHidden = false
            avatarLabel.text = player.initials
        }
        var parts: [String] = []
        if let jersey = player.jerseyDisplay { parts.append("#\(jersey)") }
        parts.append(player.position.label)
        if !player.club.isEmpty { parts.append(player.club) }
        switch highlight {
        case .currentTarget:
            parts.append(L10n.Football.Players.Picker.thisPosition)
        case .assignedOnPitch:
            parts.append(L10n.Football.Players.Picker.onPitch)
        case .assignedOnBench:
            parts.append(L10n.Football.Players.Picker.onBench)
        case .none:
            break
        }
        metaLabel.text = parts.joined(separator: " · ")
        ratingLabel.isHidden = !showsRating || player.rating == 0
        ratingLabel.text = player.rating > 0 ? "\(player.rating)" : ""
    }

    func applyTheme() {
        card.applyFootballTheme()
        nameLabel.textColor = FootballPalette.textPrimary
        metaLabel.textColor = FootballPalette.textSecondary
        ratingLabel.textColor = FootballPalette.accentGreen
        avatarView.backgroundColor = FootballPalette.surfaceElevated
        avatarLabel.backgroundColor = FootballPalette.surfaceElevated
        avatarLabel.textColor = FootballPalette.textPrimary
        applyHighlightStyle()
    }

    private func applyHighlightStyle() {
        switch highlight {
        case .none:
            card.layer.borderWidth = 0
            card.layer.borderColor = nil
        case .assignedOnPitch, .assignedOnBench:
            card.layer.borderWidth = 2
            card.layer.borderColor = FootballPalette.accentGreen.withAlphaComponent(0.45).cgColor
        case .currentTarget:
            card.layer.borderWidth = 2
            card.layer.borderColor = FootballPalette.accentGreen.cgColor
        }
    }
}
