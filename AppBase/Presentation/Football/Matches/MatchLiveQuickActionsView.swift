//
//  MatchLiveQuickActionsView.swift
//  AppBase
//

import SnapKit
import UIKit

/// Panel «Thêm sự kiện» — lưới 2×3, nhãn đầy đủ.
final class MatchLiveQuickActionsView: UIView {

    /// Chiều cao panel (title + 2 hàng chip) — đồng bộ với constraint ngoài.
    static var preferredPanelHeight: CGFloat {
        Spacing.s4 + 18 + Spacing.s8
            + MatchEventFilterChip.preferredHeight + Spacing.s8
            + MatchEventFilterChip.preferredHeight + Spacing.s8
    }

    private let titleLabel = UILabel()
    private let row1Stack = UIStackView()
    private let row2Stack = UIStackView()
    private let rowsStack = UIStackView()

    private(set) var chips: [MatchEventFilterChip] = []

    var onChipTap: ((MatchEventFilterChip) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(types: [(MatchEventType, String)]) {
        chips.forEach {
            row1Stack.removeArrangedSubview($0)
            row2Stack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        chips.removeAll()

        let mid = (types.count + 1) / 2
        for (index, item) in types.enumerated() {
            let chip = MatchEventFilterChip(type: item.0, title: item.1)
            chip.addAction(UIAction { [weak self, weak chip] _ in
                guard let self, let chip else { return }
                self.onChipTap?(chip)
            }, for: .touchUpInside)
            chips.append(chip)
            if index < mid {
                row1Stack.addArrangedSubview(chip)
            } else {
                row2Stack.addArrangedSubview(chip)
            }
        }
        applyTheme()
    }

    func applyTheme() {
        backgroundColor = FootballPalette.background
        titleLabel.textColor = FootballPalette.textSecondary
        chips.forEach { $0.applyTheme() }
    }

    private func build() {
        titleLabel.font = FootballPalette.caption(12)
        titleLabel.text = L10n.Football.Match.Live.addEvent

        [row1Stack, row2Stack].forEach {
            $0.axis = .horizontal
            $0.spacing = Spacing.s8
            $0.distribution = .fillEqually
            $0.alignment = .center
        }

        rowsStack.axis = .vertical
        rowsStack.spacing = Spacing.s8
        rowsStack.alignment = .fill
        rowsStack.addArrangedSubview(row1Stack)
        rowsStack.addArrangedSubview(row2Stack)

        addSubview(titleLabel)
        addSubview(rowsStack)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.s4).priority(.high)
            make.leading.trailing.equalToSuperview().inset(Spacing.s16)
        }
        rowsStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.s8).priority(.high)
            make.leading.trailing.equalToSuperview().inset(Spacing.s16)
        }

        clipsToBounds = true
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
}
