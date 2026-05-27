//
//  MatchLiveFinishBarView.swift
//  AppBase
//

import SnapKit
import UIKit

/// Thanh «Kết thúc trận» — outline, không chiếm chỗ cố định dưới màn hình.
final class MatchLiveFinishBarView: UIView {

    var onTap: (() -> Void)?

    private let button = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String) {
        button.setTitle(title, for: .normal)
    }

    func applyTheme() {
        backgroundColor = .clear
        button.backgroundColor = FootballPalette.surface
        button.layer.borderColor = FootballPalette.accentRed.withAlphaComponent(0.55).cgColor
        button.setTitleColor(FootballPalette.accentRed, for: .normal)
    }

    private func build() {
        button.titleLabel?.font = FootballPalette.title(15)
        button.layer.cornerRadius = Radius.s12
        button.layer.borderWidth = 1.5
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)

        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(46)
        }
    }

    @objc private func tapped() {
        onTap?()
    }
}
