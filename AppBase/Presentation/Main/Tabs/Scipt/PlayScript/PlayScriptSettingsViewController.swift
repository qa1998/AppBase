//
//  PlayScriptSettingsViewController.swift
//  AppBase
//

import SnapKit
import UIKit

final class PlayScriptSettingsViewController: UIViewController {

    var onSpeechRateChanged: ((Float) -> Void)?
    var onFontSizeChanged: ((CGFloat) -> Void)?

    private let speedValueLabel = UILabel()
    private let fontValueLabel = UILabel()
    private let speedSlider = UISlider()
    private let fontSlider = UISlider()

    private var speechRateMultiplier: Float
    private var fontSize: CGFloat

    init(
        speechRateMultiplier: Float,
        fontSize: CGFloat
    ) {

        self.speechRateMultiplier = speechRateMultiplier
        self.fontSize = fontSize

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {

        fatalError(
            "init(coder:) has not been implemented"
        )
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        setupUI()
        updateControls()
    }

    func updateValues(
        speechRateMultiplier: Float,
        fontSize: CGFloat
    ) {

        self.speechRateMultiplier = speechRateMultiplier
        self.fontSize = fontSize

        updateControls()
    }

    private func setupUI() {

        let colors =
            ThemeManager.shared.colors

        title = L10n.teleprompterSettingsTitle

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(
                title: L10n.teleprompterSettingsDone,
                style: .done,
                target: self,
                action: #selector(onClose)
            )

        view.backgroundColor =
            colors.backgroundSecondary

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 18

        view.addSubview(stack)

        stack.snp.makeConstraints {

            $0.top.equalTo(
                view.safeAreaLayoutGuide.snp.top
            ).offset(24)

            $0.leading.trailing.equalToSuperview()
                .inset(20)
        }

        configureSliders()

        stack.addArrangedSubview(
            makeSliderRow(
                title: L10n.teleprompterSettingsSpeechRateTitle,
                caption: L10n.teleprompterSettingsSpeechRateCaption,
                valueLabel: speedValueLabel,
                slider: speedSlider
            )
        )

        stack.addArrangedSubview(
            makeSliderRow(
                title: L10n.teleprompterSettingsFontSizeTitle,
                caption: L10n.teleprompterSettingsFontSizeCaption,
                valueLabel: fontValueLabel,
                slider: fontSlider
            )
        )
    }

    private func configureSliders() {

        speedSlider.minimumValue = 0.55
        speedSlider.maximumValue = 1.7
        speedSlider.isContinuous = true
        speedSlider.minimumTrackTintColor =
            ThemeManager.shared.colors.teleprompterControlTint
        speedSlider.maximumTrackTintColor =
            ThemeManager.shared.colors.teleprompterSliderTrack
        speedSlider.addTarget(
            self,
            action: #selector(onSpeedSliderChanged),
            for: .valueChanged
        )
        speedSlider.addTarget(
            self,
            action: #selector(onSpeedSliderEditingEnded),
            for: [
                .touchUpInside,
                .touchUpOutside,
                .touchCancel
            ]
        )

        fontSlider.minimumValue = 24
        fontSlider.maximumValue = 54
        fontSlider.isContinuous = true
        fontSlider.minimumTrackTintColor =
            ThemeManager.shared.colors.teleprompterControlTint
        fontSlider.maximumTrackTintColor =
            ThemeManager.shared.colors.teleprompterSliderTrack
        fontSlider.addTarget(
            self,
            action: #selector(onFontSliderChanged),
            for: .valueChanged
        )
    }

    private func makeSliderRow(
        title: String,
        caption: String,
        valueLabel: UILabel,
        slider: UISlider
    ) -> UIView {

        let colors =
            ThemeManager.shared.colors

        let container = UIView()
        container.backgroundColor =
            colors.teleprompterCardBackground
        container.layer.cornerRadius = 18

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor =
            colors.teleprompterTextCurrent
        titleLabel.font =
            .systemFont(
                ofSize: 16,
                weight: .medium
            )

        let captionLabel = UILabel()
        captionLabel.text = caption
        captionLabel.textColor =
            colors.teleprompterTextSecondary
        captionLabel.font =
            .systemFont(
                ofSize: 13,
                weight: .regular
            )

        valueLabel.textColor =
            colors.teleprompterTextRead
        valueLabel.font =
            .monospacedDigitSystemFont(
                ofSize: 15,
                weight: .medium
            )

        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        container.addSubview(captionLabel)
        container.addSubview(slider)

        container.snp.makeConstraints {

            $0.height.equalTo(128)
        }

        titleLabel.snp.makeConstraints {

            $0.leading.equalToSuperview()
                .offset(18)

            $0.top.equalToSuperview()
                .offset(18)
        }

        valueLabel.snp.makeConstraints {

            $0.trailing.equalToSuperview()
                .offset(-18)

            $0.centerY.equalTo(titleLabel)
        }

        captionLabel.snp.makeConstraints {

            $0.leading.equalTo(titleLabel)

            $0.top.equalTo(titleLabel.snp.bottom)
                .offset(6)
        }

        slider.snp.makeConstraints {

            $0.leading.trailing.equalToSuperview()
                .inset(18)

            $0.top.equalTo(captionLabel.snp.bottom)
                .offset(16)
        }

        return container
    }

    private func updateControls() {

        speedSlider.value = speechRateMultiplier
        fontSlider.value = Float(fontSize)

        speedValueLabel.text =
            L10n.teleprompterSettingsPercentFormat(
                speechRateMultiplier * 100
            )

        fontValueLabel.text =
            L10n.teleprompterSettingsFontPointFormat(
                fontSize
            )
    }

    @objc
    private func onSpeedSliderChanged() {

        let value =
            speedSlider.value

        speechRateMultiplier = value
        updateControls()
    }

    @objc
    private func onSpeedSliderEditingEnded() {

        onSpeechRateChanged?(
            speechRateMultiplier
        )
    }

    @objc
    private func onFontSliderChanged() {

        let value =
            CGFloat(
                fontSlider.value.rounded()
            )

        fontSize = value
        updateControls()
        onFontSizeChanged?(
            value
        )
    }

    @objc
    private func onClose() {

        dismiss(
            animated: true
        )
    }
}
