//
//  EditorToolTabBar.swift
//  AppBase
//

import SnapKit
import UIKit

enum EditorToolMode: Int, CaseIterable {
    case formation = 0
    case fields = 1
    case arrows = 2

    var iconName: String {
        switch self {
        case .formation: return "point.3.connected.trianglepath.dotted"
        case .fields: return "soccerball"
        case .arrows: return "arrow.turn.up.right"
        }
    }

    var title: String {
        switch self {
        case .formation: return L10n.Football.Editor.Tool.formation
        case .fields: return L10n.Football.Editor.Tool.fields
        case .arrows: return L10n.Football.Editor.Tool.arrows
        }
    }
}

/// Formation · Fields · Arrows — red icon tabs on dark surface.
final class EditorToolTabBar: UIView {

    var selectedMode: EditorToolMode = .formation

    var onModeChanged: ((EditorToolMode) -> Void)?

    private let stack = UIStackView()
    private var tabViews: [EditorToolTabItem] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = FootballPalette.surface
        layer.cornerRadius = Radius.s12
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
        EditorToolMode.allCases.forEach { mode in
            let item = EditorToolTabItem(mode: mode)
            item.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(item)
            tabViews.append(item)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refreshTitles() {
        tabViews.forEach { $0.refreshTitle() }
    }

    @objc private func tabTapped(_ sender: EditorToolTabItem) {
        selectedMode = sender.mode
        onModeChanged?(sender.mode)
    }
}

private final class EditorToolTabItem: UIControl {

    let mode: EditorToolMode
    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    init(mode: EditorToolMode) {
        self.mode = mode
        super.init(frame: .zero)
        iconView.image = UIImage(systemName: mode.iconName)
        iconView.contentMode = .scaleAspectFit
        titleLabel.font = FootballPalette.caption(10)
        titleLabel.textAlignment = .center
        refreshTitle()
        let column = UIStackView(arrangedSubviews: [iconView, titleLabel])
        column.axis = .vertical
        column.spacing = 6
        column.alignment = .center
        column.isUserInteractionEnabled = false
        addSubview(column)
        column.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(Spacing.s12)
        }
        iconView.snp.makeConstraints { $0.size.equalTo(22) }
        tintItems()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refreshTitle() {
        titleLabel.text = mode.title
    }

    private func tintItems() {
        iconView.tintColor = FootballPalette.accentRed
        titleLabel.textColor = FootballPalette.accentRed
        alpha = 1
    }
}
