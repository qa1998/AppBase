//
//  FootballPlayerTokenView.swift
//  AppBase
//

import UIKit
import SnapKit

protocol FootballPlayerTokenViewDelegate: AnyObject {
    func playerTokenDidMove(_ token: FootballPlayerTokenView, normalizedPosition: CGPoint)
    func playerTokenDidTap(_ token: FootballPlayerTokenView)
}

enum FootballPlayerTokenSize {
    case pitch
    case bench

    var circleDiameter: CGFloat {
        switch self {
        case .pitch: return 38
        case .bench: return 28
        }
    }

    var initialsFontSize: CGFloat {
        switch self {
        case .pitch: return 11
        case .bench: return 9
        }
    }

    var nameFontSize: CGFloat {
        switch self {
        case .pitch: return 8
        case .bench: return 6
        }
    }

    var emptyPlusFontSize: CGFloat {
        switch self {
        case .pitch: return 22
        case .bench: return 16
        }
    }

    /// Gap between circle bottom and name pill (overlap applied in layout).
    var nameTopOverlap: CGFloat {
        switch self {
        case .pitch: return 4
        case .bench: return 3
        }
    }

    /// Fixed name area height (up to 2 lines); avatar stays a separate circle above.
    var namePillMaxHeight: CGFloat {
        switch self {
        case .pitch: return 22
        case .bench: return 16
        }
    }

    /// Total token height = round avatar + name block.
    var fixedTokenHeight: CGFloat {
        circleDiameter + nameTopOverlap + namePillMaxHeight
    }
}

/// Player token on pitch or bench — filled circle + name, or empty dashed slot with +.
final class FootballPlayerTokenView: UIView {

    weak var delegate: FootballPlayerTokenViewDelegate?

    let slotIndex: Int
    private(set) var player: FootballPlayer?
    var tokenSize: FootballPlayerTokenSize = .pitch

    private let circleView = UIView()
    private let avatarImageView = UIImageView()
    private let avatarLabel = UILabel()
    private let namePill = PaddingLabel()
    private let innerGlow = CALayer()
    private let dashedLayer = CAShapeLayer()

    var normalizedPosition: CGPoint = .zero
    /// Set by `PitchPlayerTokenLayout` from grid slot width.
    var gridLabelMaxWidth: CGFloat?
    /// Kéo thả trên sân — mặc định tắt (vị trí theo formation).
    var allowsDrag = false

    init(slotIndex: Int, player: FootballPlayer?, size: FootballPlayerTokenSize = .pitch) {
        self.slotIndex = slotIndex
        self.player = player
        self.tokenSize = size
        super.init(frame: .zero)
        setup()
        configure(player: player)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var intrinsicContentSize: CGSize {
        preferredTokenSize
    }

    /// Avatar is always a fixed circle; only label width varies.
    private var avatarDiameter: CGFloat { tokenSize.circleDiameter }

    var preferredTokenSize: CGSize {
        let circle = avatarDiameter
        guard !namePill.isHidden else {
            return CGSize(width: circle, height: circle)
        }
        let labelCap = gridLabelMaxWidth ?? .greatestFiniteMagnitude
        let nameWidth = Self.measureNamePillWidth(namePill, maxWidth: labelCap)
        return CGSize(
            width: max(circle, nameWidth),
            height: tokenSize.fixedTokenHeight
        )
    }

    /// Label width only (height is fixed via `FootballPlayerTokenSize.namePillHeight`).
    static func measureNamePillWidth(_ label: PaddingLabel, maxWidth: CGFloat) -> CGFloat {
        guard let text = label.text, !text.isEmpty, let font = label.font else { return 0 }
        let insets = label.textInsets
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let maxTextWidth = max(1, maxWidth - insets.left - insets.right)
        let natural = (text as NSString).boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: font.lineHeight),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attrs,
            context: nil
        )
        let textWidth = min(ceil(natural.width), maxTextWidth)
        return min(textWidth + insets.left + insets.right, maxWidth)
    }
    func configure(player: FootballPlayer?) {
        self.player = player
        let isEmpty = player == nil
        circleView.isHidden = isEmpty
        avatarImageView.isHidden = isEmpty
        avatarLabel.isHidden = isEmpty
        namePill.isHidden = isEmpty
        dashedLayer.isHidden = !isEmpty
        plusLabel.isHidden = !isEmpty

        if let player {
            let circleText = player.jerseyDisplay ?? player.initials
            if let image = player.avatarImage {
                avatarImageView.image = image
                avatarImageView.isHidden = false
                avatarLabel.isHidden = player.jerseyDisplay == nil
                avatarLabel.text = nil
            } else {
                avatarImageView.image = nil
                avatarImageView.isHidden = true
                avatarLabel.isHidden = false
                avatarLabel.text = nil
            }
            namePill.text = FootballPlayerTokenView.displayName(player)
            innerGlow.backgroundColor = FootballPalette.accentRed.withAlphaComponent(0.35).cgColor
        }
        updateEmptyAppearance()
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    private lazy var plusLabel: UILabel = {
        let label = UILabel()
        label.text = "+"
        label.textColor = FootballPalette.textPrimary
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private func updateEmptyAppearance() {
        plusLabel.font = FootballPalette.title(tokenSize.emptyPlusFontSize)
        let dashColor: UIColor = tokenSize == .bench
            ? FootballPalette.pitchLine.withAlphaComponent(0.6)
            : UIColor.white.withAlphaComponent(0.7)
        dashedLayer.strokeColor = dashColor.cgColor
    }

    private func setup() {
        let metrics = tokenSize
        let circle = metrics.circleDiameter

        translatesAutoresizingMaskIntoConstraints = false

        layer.addSublayer(dashedLayer)
        addSubview(plusLabel)

        circleView.backgroundColor = FootballPalette.pitchGreen
        circleView.layer.borderWidth = 2
        circleView.layer.borderColor = UIColor.white.cgColor
        circleView.clipsToBounds = true

        addSubview(circleView)

        circleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(circle)
        }

        circleView.layer.insertSublayer(innerGlow, at: 0)

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true

        avatarLabel.font = FootballPalette.caption(metrics.initialsFontSize)
        avatarLabel.textColor = .white
        avatarLabel.textAlignment = .center

        circleView.addSubview(avatarImageView)
        circleView.addSubview(avatarLabel)

        avatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        avatarLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        namePill.font = FootballPalette.caption(metrics.nameFontSize)
        namePill.textColor = .white
        namePill.textAlignment = .center
        namePill.numberOfLines = 2
        namePill.lineBreakMode = .byTruncatingTail
        namePill.adjustsFontSizeToFitWidth = false
        namePill.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        namePill.layer.cornerRadius = 6
        namePill.clipsToBounds = true

        addSubview(namePill)

        namePill.snp.makeConstraints { make in
            make.top.equalTo(circleView.snp.bottom).offset(metrics.nameTopOverlap)
            make.centerX.equalToSuperview()
            make.height.equalTo(metrics.namePillMaxHeight)
            make.width.lessThanOrEqualToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
        }
        namePill.setContentHuggingPriority(.required, for: .horizontal)
        namePill.setContentCompressionResistancePriority(.required, for: .horizontal)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !namePill.isHidden, let cap = gridLabelMaxWidth {
            namePill.preferredMaxLayoutWidth = max(
                1,
                cap - namePill.textInsets.left - namePill.textInsets.right
            )
        }

        let d = avatarDiameter
        circleView.layer.cornerRadius = d / 2
        let avatarInset: CGFloat = 4
        let innerSize = d - avatarInset * 2
        avatarImageView.layer.cornerRadius = innerSize / 2
        innerGlow.frame = circleView.bounds.insetBy(dx: avatarInset, dy: avatarInset)
        innerGlow.cornerRadius = innerSize / 2
        let dashRect = CGRect(x: bounds.midX - d / 2, y: 0, width: d, height: d)
        dashedLayer.path = UIBezierPath(ovalIn: dashRect).cgPath
        dashedLayer.fillColor = UIColor.clear.cgColor
        dashedLayer.lineWidth = 1.5
        dashedLayer.lineDashPattern = tokenSize == .bench ? [4, 4] : [5, 5]
        updateEmptyAppearance()
        plusLabel.center = CGPoint(x: bounds.midX, y: d / 2)
    }

    static func displayName(_ player: FootballPlayer) -> String {
        let parts = player.name.split(separator: " ")
        guard parts.count >= 2 else {
            return player.name.uppercased()
        }
        let initial = String(parts[0].prefix(1))
        let last = parts.last.map(String.init) ?? ""
        return "\(initial). \(last.uppercased())"
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard allowsDrag, player != nil, let pitch = superview else { return }
        let translation = gesture.translation(in: pitch)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        gesture.setTranslation(.zero, in: pitch)
        let nx = (center.x - pitch.bounds.minX) / pitch.bounds.width
        let ny = (center.y - pitch.bounds.minY) / pitch.bounds.height
        let clamped = CGPoint(x: min(max(nx, 0.05), 0.95), y: min(max(ny, 0.05), 0.95))
        normalizedPosition = clamped
        if gesture.state == .ended {
            delegate?.playerTokenDidMove(self, normalizedPosition: clamped)
        }
    }

    @objc private func handleTap() {
        delegate?.playerTokenDidTap(self)
    }
}
