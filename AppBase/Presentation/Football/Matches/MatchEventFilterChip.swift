//
//  MatchEventFilterChip.swift
//  AppBase
//

import SnapKit
import UIKit

/// Nút quick action thêm sự kiện trên màn live (không có trạng thái chọn).
final class MatchEventFilterChip: UIControl {

    var eventType: MatchEventType?

    private let iconView = UIImageView()
    private let cardIconView = UIView()
    private let titleLabel = UILabel()

    override var isHighlighted: Bool {
        didSet { applyAppearance() }
    }

    init(type: MatchEventType, title: String) {
        eventType = type
        super.init(frame: .zero)
        titleLabel.text = title
        build()
        applyAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyTheme() {
        applyAppearance()
    }

    private func build() {
        layer.cornerRadius = 20
        clipsToBounds = true

        iconView.contentMode = .scaleAspectFit

        titleLabel.font = FootballPalette.caption(12)
        titleLabel.textAlignment = .center

        addSubview(iconView)
        addSubview(cardIconView)
        addSubview(titleLabel)

        snp.makeConstraints { $0.height.equalTo(40) }

        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.s12)
            make.centerY.equalToSuperview()
            make.size.equalTo(18)
        }
        cardIconView.snp.makeConstraints { make in
            make.center.equalTo(iconView)
            make.width.equalTo(12)
            make.height.equalTo(16)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(Spacing.s6)
            make.trailing.equalToSuperview().inset(Spacing.s12)
            make.centerY.equalToSuperview()
        }
    }

    private func applyAppearance() {
        guard let type = eventType else { return }
        configureIcon(type: type)

        backgroundColor = FootballPalette.surfaceElevated
        titleLabel.textColor = FootballPalette.textPrimary
        iconView.tintColor = iconTint(for: type)
        if type == .yellowCard || type == .redCard {
            cardIconView.backgroundColor = iconTint(for: type)
        }
        alpha = isHighlighted ? 0.72 : 1
    }

    private func iconTint(for type: MatchEventType) -> UIColor {
        switch type {
        case .goal, .penalty: return FootballPalette.accentGreen
        case .yellowCard: return UIColor(hex: 0xFACC15)
        case .redCard: return FootballPalette.accentRed
        case .substitution, .varReview: return FootballPalette.textPrimary
        }
    }

    private func configureIcon(type: MatchEventType) {
        iconView.backgroundColor = .clear
        iconView.layer.cornerRadius = 0
        switch type {
        case .yellowCard, .redCard:
            iconView.isHidden = true
            cardIconView.isHidden = false
            cardIconView.backgroundColor = iconTint(for: type)
        default:
            cardIconView.isHidden = true
            iconView.isHidden = false
            iconView.image = UIImage(systemName: type.iconName)
        }
    }
}
