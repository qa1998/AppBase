//
//  LineupListCell.swift
//  AppBase
//

import SnapKit
import UIKit

final class LineupListCell: UITableViewCell {

    static let reuseId = "LineupListCell"

    var onMoreTap: (() -> Void)?

    private let card = UIView()
    private let miniPitch = LineupMiniPitchView()
    private let titleLabel = UILabel()
    private let moreButton = UIButton(type: .system)
    private let formationTag = PaddingLabel()
    private let styleTag = PaddingLabel()
    private let editedIcon = UIImageView()
    private let editedLabel = UILabel()
    private var tacticalStyle: TacticalStyle = .balanced

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        card.backgroundColor = FootballPalette.surface
        card.layer.cornerRadius = Radius.s16

        titleLabel.font = FootballPalette.title(16)
        titleLabel.textColor = FootballPalette.textPrimary

        moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        moreButton.tintColor = FootballPalette.textSecondary
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)

        configureFormationTag(formationTag)
        configureStyleTag(styleTag)

        editedIcon.image = UIImage(systemName: "clock")
        editedIcon.tintColor = FootballPalette.textSecondary
        editedIcon.contentMode = .scaleAspectFit
        editedLabel.font = FootballPalette.caption(11)
        editedLabel.textColor = FootballPalette.textSecondary

        contentView.addSubview(card)
        card.addSubview(miniPitch)
        card.addSubview(titleLabel)
        card.addSubview(moreButton)
        card.addSubview(formationTag)
        card.addSubview(styleTag)
        card.addSubview(editedIcon)
        card.addSubview(editedLabel)

        card.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 20, bottom: 6, right: 20))
        }
        miniPitch.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(Spacing.s12)
            make.width.equalTo(72)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(miniPitch.snp.trailing).offset(Spacing.s12)
            make.top.equalToSuperview().offset(Spacing.s14)
            make.trailing.lessThanOrEqualTo(moreButton.snp.leading).offset(-Spacing.s8)
        }
        moreButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Spacing.s12)
            make.top.equalToSuperview().offset(Spacing.s12)
            make.size.equalTo(32)
        }
        formationTag.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.s8)
        }
        styleTag.snp.makeConstraints { make in
            make.leading.equalTo(formationTag.snp.trailing).offset(Spacing.s8)
            make.centerY.equalTo(formationTag)
        }
        editedIcon.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(formationTag.snp.bottom).offset(Spacing.s8)
            make.bottom.equalToSuperview().inset(Spacing.s14)
            make.size.equalTo(14)
        }
        editedLabel.snp.makeConstraints { make in
            make.leading.equalTo(editedIcon.snp.trailing).offset(4)
            make.centerY.equalTo(editedIcon)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with lineup: FootballLineup) {
        tacticalStyle = lineup.tacticalStyle
        miniPitch.lineup = lineup
        titleLabel.text = lineup.displayTitle
        formationTag.text = lineup.formation.name
        styleTag.text = lineup.tacticalStyle.label
        editedLabel.text = lineup.relativeEditedText
        applyFormationTagAppearance()
        applyStyleTagAppearance()
        miniPitch.setNeedsDisplay()
    }

    func applyTheme() {
        card.backgroundColor = FootballPalette.surface
        titleLabel.textColor = FootballPalette.textPrimary
        moreButton.tintColor = FootballPalette.textSecondary
        applyFormationTagAppearance()
        applyStyleTagAppearance()
        editedIcon.tintColor = FootballPalette.textSecondary
        editedLabel.textColor = FootballPalette.textSecondary
        miniPitch.backgroundColor = FootballPalette.surfaceElevated
        miniPitch.setNeedsDisplay()
    }

    private func configureFormationTag(_ label: UILabel) {
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
    }

    private func configureStyleTag(_ label: UILabel) {
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
    }

    private func applyFormationTagAppearance() {
        let colors = tacticalStyle.formationBadgeColors
        formationTag.backgroundColor = colors.background
        formationTag.textColor = colors.foreground
    }

    private func applyStyleTagAppearance() {
        let colors = tacticalStyle.badgeColors
        styleTag.backgroundColor = colors.background
        styleTag.textColor = colors.foreground
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        [formationTag, styleTag].forEach { label in
            guard let text = label.text else { return }
            let width = text.size(withAttributes: [.font: label.font!]).width + 16
            label.bounds.size = CGSize(width: width, height: 22)
        }
    }

    @objc private func moreTapped() {
        onMoreTap?()
    }
}
