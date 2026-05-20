//
//  TIOCollectionViewCell.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
import SnapKit

class TIOCollectionViewCell: UICollectionViewCell, ShimmeringViewProtocol, TIOListCellShimmerApplicable, TIOThemable {

    static var reuseIdentifier: String {
        return String(describing: self)
    }

    var shimmeringAnimatedItems: [UIView] { [shimmerHost] }

    private let shimmerHost: TIOView = {
        let view = TIOView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.bringSubviewToFront(shimmerHost)
    }

    func applyTheme(_ colors: ThemeColors) {
        backgroundColor = colors.backgroundPrimary
        contentView.backgroundColor = colors.backgroundPrimary
    }

    func applyListShimmer(_ isLoading: Bool) {
        shimmerHost.isHidden = !isLoading
        shimmerHost.setTemplateWithSubviews(
            isLoading,
            viewBackgroundColor: ThemeManager.shared.palette.backgroundSecondary
        )
    }

    func setupLayout() {

    }

    func updateDisplay(data: Any?) {

    }

    class func cellSize(data: Any?) -> CGSize {
        return .zero
    }

    private func commonInit() {
        contentView.addSubview(shimmerHost)
        shimmerHost.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        startTheming()
    }
}
