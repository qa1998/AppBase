//
//  HomeBankCell.swift
//  AppBase
//

import Kingfisher
import UIKit

final class HomeBankCell: TIOTableViewCell {

    private static let placeholder = UIImage(systemName: "building.2")

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure(with bank: Bank) {
        textLabel?.text = bank.shortName
        textLabel?.font = Font.bold(size: .text17)
        detailTextLabel?.text = bank.subtitle
        detailTextLabel?.font = Font.default(size: .text13)
        detailTextLabel?.numberOfLines = 2
        imageView?.contentMode = .scaleAspectFit
        imageView?.kf.setImage(
            with: bank.logoURL,
            placeholder: Self.placeholder,
            options: [.transition(.fade(0.2)), .cacheOriginalImage]
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.kf.cancelDownloadTask()
        imageView?.image = Self.placeholder
    }
}
