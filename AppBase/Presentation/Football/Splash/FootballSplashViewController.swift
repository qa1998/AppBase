//
//  FootballSplashViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import SnapKit
import UIKit

final class FootballSplashViewController: FootballScreenViewController<FootballSplashViewModel> {

    private let logoContainer = UIView()
    private let logoImageView = UIImageView()
    private let brandLabel = UILabel()
    private let taglineLabel = UILabel()
    private let glowRing = CAShapeLayer()

    override func setupUI() {
        super.setupUI()
        

        logoImageView.image = UIImage(systemName: "sportscourt.fill")
        logoImageView.tintColor = FootballPalette.accentGreen
        logoImageView.contentMode = .scaleAspectFit

        brandLabel.text = L10n.Football.brand
        brandLabel.font = FootballPalette.headline(32)
        brandLabel.textColor = FootballPalette.textPrimary
        brandLabel.textAlignment = .center

        taglineLabel.text = L10n.Football.tagline
        taglineLabel.font = FootballPalette.body(14)
        taglineLabel.textColor = FootballPalette.textSecondary
        taglineLabel.textAlignment = .center

        view.addSubview(logoContainer)
        logoContainer.addSubview(logoImageView)
        view.addSubview(brandLabel)
        view.addSubview(taglineLabel)

        logoContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.size.equalTo(120)
        }
        logoImageView.snp.makeConstraints { $0.center.equalToSuperview(); $0.size.equalTo(72) }
        brandLabel.snp.makeConstraints { make in
            make.top.equalTo(logoContainer.snp.bottom).offset(Spacing.s24)
            make.leading.trailing.equalToSuperview().inset(Spacing.s32)
        }
        taglineLabel.snp.makeConstraints { make in
            make.top.equalTo(brandLabel.snp.bottom).offset(Spacing.s8)
            make.leading.trailing.equalTo(brandLabel)
        }

        logoContainer.layer.addSublayer(glowRing)
        animateLogo()
    }

    override func onBind() {
        super.onBind()
        viewModel.didFinish
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.onSplashFinished?()
            }
            .store(in: &cancelBag)
        viewModel.start()
    }

    var onSplashFinished: (() -> Void)?

    private func animateLogo() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 0.92
        pulse.toValue = 1.06
        pulse.duration = 1.1
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        logoImageView.layer.add(pulse, forKey: "pulse")

        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.fromValue = 0.35
        opacity.toValue = 0.85
        opacity.duration = 1.4
        opacity.autoreverses = true
        opacity.repeatCount = .infinity
        glowRing.add(opacity, forKey: "glow")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let path = UIBezierPath(
            ovalIn: logoContainer.bounds.insetBy(dx: 4, dy: 4)
        )
        glowRing.path = path.cgPath
        glowRing.fillColor = UIColor.clear.cgColor
        glowRing.strokeColor = FootballPalette.accentGreen.cgColor
        glowRing.lineWidth = 2
    }
}
