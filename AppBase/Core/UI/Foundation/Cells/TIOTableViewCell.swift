//
//  TIOTableViewCell.swift
//  AppBase
//
//  Created by QuangAnh on 11/5/26.
//

import UIKit
import SnapKit

class TIOTableViewCell: UITableViewCell, ShimmeringViewProtocol, TIOListCellShimmerApplicable {

    var isEnableHighlight: Bool {
        return true
    }

    static var reuseIdentifier: String {
        return String(describing: self)
    }

    static var nib: UINib {
        UINib(nibName: String(describing: self), bundle: .main)
    }

    var selectedColor: UIColor {
        return .gray
    }

    var shimmeringAnimatedItems: [UIView] { [shimmerHost] }

    private let shimmerHost: TIOView = {
        let view = TIOView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()

    class func cellHeight(for data: Any?) -> CGFloat {
        return 56.0
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.bringSubviewToFront(shimmerHost)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        guard isEnableHighlight else { return }
        super.setSelected(selected, animated: animated)
        if isEditing && selected {
            let highlightView = UIView(frame: contentView.frame)
            highlightView.backgroundColor = .clear
            selectedBackgroundView = highlightView
        }
    }

    func applyListShimmer(_ isLoading: Bool) {
        shimmerHost.isHidden = !isLoading
        shimmerHost.setTemplateWithSubviews(
            isLoading,
            viewBackgroundColor: .secondarySystemGroupedBackground
        )
        textLabel?.isHidden = isLoading
        detailTextLabel?.isHidden = isLoading
        imageView?.isHidden = isLoading
    }

    func updateDisplay(with data: Any?) {

    }

    private func commonInit() {
        backgroundColor = ThemeManager.shared.colors.backgroundPrimary
        separatorInset = .zero

        let selectedView = UIView(frame: .zero)
        selectedView.backgroundColor = selectedColor
        selectedBackgroundView = selectedView

        contentView.addSubview(shimmerHost)
        shimmerHost.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
    }
}
