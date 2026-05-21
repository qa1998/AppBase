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

    var viewSize: CGSize {
        switch self {
        case .pitch: return CGSize(width: 48, height: 56)
        case .bench: return CGSize(width: 36, height: 40)
        }
    }

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
    private let namePill = UILabel()
    private let innerGlow = CALayer()
    private let dashedLayer = CAShapeLayer()

    var normalizedPosition: CGPoint = .zero
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
        tokenSize.viewSize
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
                avatarLabel.text = player.jerseyDisplay
            } else {
                avatarImageView.image = nil
                avatarImageView.isHidden = true
                avatarLabel.isHidden = false
                avatarLabel.text = circleText
            }
            namePill.text = FootballPlayerTokenView.displayName(player)
            innerGlow.backgroundColor = FootballPalette.accentRed.withAlphaComponent(0.35).cgColor
        }
        updateEmptyAppearance()
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
        circleView.layer.cornerRadius = circle / 2
        circleView.layer.borderWidth = 2
        circleView.layer.borderColor = UIColor.white.cgColor

        addSubview(circleView)

        circleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(circle)
        }

        innerGlow.cornerRadius = (circle - 8) / 2
        circleView.layer.insertSublayer(innerGlow, at: 0)

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = (circle - 8) / 2

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
        namePill.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        namePill.layer.cornerRadius = 6
        namePill.clipsToBounds = true

        addSubview(namePill)

        namePill.snp.makeConstraints { make in
            make.top.equalTo(circleView.snp.bottom).offset(3)
            make.centerX.equalTo(circleView)
            make.height.equalTo(tokenSize == .bench ? 12 : 14)
            make.width.greaterThanOrEqualTo(circle)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
        }

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        innerGlow.frame = circleView.bounds.insetBy(dx: 4, dy: 4)
        innerGlow.cornerRadius = innerGlow.bounds.width / 2
        let d = tokenSize.circleDiameter
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
