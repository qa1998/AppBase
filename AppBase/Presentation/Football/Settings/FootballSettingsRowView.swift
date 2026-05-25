//
//  FootballSettingsRowView.swift
//  AppBase
//

import SnapKit
import UIKit

final class FootballSettingsRowView: FootballGlassView {

    var onTap: (() -> Void)?

    var showsChevron = true {
        didSet { chevronView.isHidden = !showsChevron }
    }

    var usesDestructiveStyle = false {
        didSet { applyTitleStyle() }
    }

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevronView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build() {
        titleLabel.font = FootballPalette.title(15)
        valueLabel.font = FootballPalette.caption()
        valueLabel.textAlignment = .right
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        chevronView.image = UIImage(systemName: "chevron.right")
        chevronView.tintColor = FootballPalette.textSecondary
        chevronView.contentMode = .scaleAspectFit

        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(chevronView)

        titleLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(Spacing.s12)
        }
        chevronView.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview().inset(Spacing.s12)
            make.size.equalTo(18)
        }
        valueLabel.snp.makeConstraints { make in
            make.trailing.equalTo(chevronView.snp.leading).offset(-Spacing.s8)
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(Spacing.s8)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
        snp.makeConstraints { $0.height.greaterThanOrEqualTo(52) }
        applyTitleStyle()
    }

    func configure(title: String, value: String? = nil) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.isHidden = value == nil
    }

    func applyTheme() {
        valueLabel.textColor = FootballPalette.textSecondary
        chevronView.tintColor = FootballPalette.textSecondary
        applyTitleStyle()
    }

    private func applyTitleStyle() {
        titleLabel.textColor = usesDestructiveStyle
            ? FootballPalette.accentRed
            : FootballPalette.textPrimary
    }

    @objc private func handleTap() {
        guard showsChevron else { return }
        onTap?()
    }
}
