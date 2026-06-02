//
//  MatchEventFilterChip.swift
//  AppBase
//

import SnapKit
import UIKit

/// Nút thêm sự kiện nhanh — icon + nhãn đầy đủ, màu theo loại sự kiện.
final class MatchEventFilterChip: UIControl {

    static let preferredHeight: CGFloat = 60

    var eventType: MatchEventType?

    private let iconContainer = UIView()
    private let iconView = UIImageView()
    private let cardIconView = UIView()
    private let titleLabel = UILabel()

    override var isHighlighted: Bool {
        didSet { updateHighlight() }
    }

    init(type: MatchEventType, title: String) {
        eventType = type
        super.init(frame: .zero)
        titleLabel.text = title
        build()
        applyTheme()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyTheme() {
        guard let type = eventType else { return }
        configureIcon(type: type)

        titleLabel.textColor = FootballPalette.textPrimary
        layer.borderColor = accentColor(for: type).withAlphaComponent(0.45).cgColor
        iconContainer.backgroundColor = accentColor(for: type).withAlphaComponent(0.14)
        backgroundColor = FootballPalette.surface
        updateHighlight()
    }

    private func build() {
        layer.cornerRadius = Radius.s12
        layer.borderWidth = 1
        clipsToBounds = true

        iconContainer.layer.cornerRadius = 15
        iconContainer.clipsToBounds = true
        iconView.contentMode = .scaleAspectFit

        cardIconView.layer.cornerRadius = 2
        cardIconView.isHidden = true

        titleLabel.font = FootballPalette.caption(11)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.85

        addSubview(iconContainer)
        iconContainer.addSubview(iconView)
        iconContainer.addSubview(cardIconView)
        addSubview(titleLabel)

        snp.makeConstraints { make in
            make.height.equalTo(Self.preferredHeight).priority(.high)
        }
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        iconContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.s6)
            make.centerX.equalToSuperview()
            make.size.equalTo(30)
        }
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(18)
        }
        cardIconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(11)
            make.height.equalTo(14)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainer.snp.bottom).offset(Spacing.s4)
            make.leading.trailing.equalToSuperview().inset(Spacing.s4)
            make.bottom.equalToSuperview().inset(Spacing.s6)
        }
    }

    private func updateHighlight() {
        alpha = isHighlighted ? 0.65 : 1
        transform = isHighlighted
            ? CGAffineTransform(scaleX: 0.96, y: 0.96)
            : .identity
    }

    private func accentColor(for type: MatchEventType) -> UIColor {
        switch type {
        case .goal, .penalty: return FootballPalette.accentGreen
        case .yellowCard: return UIColor(hex: 0xFACC15)
        case .redCard: return FootballPalette.accentRed
        case .substitution: return FootballPalette.textSecondary
        case .varReview: return FootballPalette.textSecondary
        }
    }

    private func configureIcon(type: MatchEventType) {
        switch type {
        case .yellowCard, .redCard:
            iconView.isHidden = true
            cardIconView.isHidden = false
            cardIconView.backgroundColor = accentColor(for: type)
        default:
            cardIconView.isHidden = true
            iconView.isHidden = false
            iconView.tintColor = accentColor(for: type)
            iconView.image = UIImage(systemName: type.iconName)
        }
    }
}
