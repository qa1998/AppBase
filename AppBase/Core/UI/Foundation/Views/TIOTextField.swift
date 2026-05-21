//
//  TIOTextField.swift
//  AppBase
//

import SnapKit
import UIKit

/// Text field theo theme — placeholder set từ VC (`refreshLocalization`).
class TIOTextField: UITextField, TIOThemable {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        font = Font.default(size: .text17)
        borderStyle = .none
        layer.cornerRadius = Radius.s12
        layer.borderWidth = 1
        layer.masksToBounds = true
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: Spacing.s12, height: 1))
        leftViewMode = .always
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: Spacing.s12, height: 1))
        rightViewMode = .always
        startTheming()
    }

    func applyTheme(_ colors: ThemeColors) {
        backgroundColor = colors.backgroundPrimary
        textColor = colors.textPrimary
        tintColor = colors.primary
        layer.borderColor = colors.separator.cgColor
        updatePlaceholderColor(colors.textSecondary)
    }

    private func updatePlaceholderColor(_ color: UIColor) {
        guard let placeholder else { return }
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: color,
                .font: Font.default(size: .text17)
            ]
        )
    }

    override var placeholder: String? {
        didSet {
            updatePlaceholderColor(ThemeManager.shared.palette.textSecondary)
        }
    }
}
