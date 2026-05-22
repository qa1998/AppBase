//
//  LineupExportViewController.swift
//  AppBase
//

import BaseMVVM
import SnapKit
import UIKit

final class LineupExportViewModel: TIOViewModel<TIOLoadingTarget> {}

final class LineupExportViewController: FootballScreenViewController<LineupExportViewModel> {

    private let previewCard = FootballGlassView()
    private let previewPitch = FootballPitchView()
    private let previewTitleLabel = UILabel()
    private let templateStack = UIStackView()
    private let downloadButton = FootballNeonButton(title: "", style: .primary)
    private let shareButton = FootballNeonButton(title: "", style: .secondary)

    override func setupUI() {
        super.setupUI()
        refreshLocalization()

        previewTitleLabel.font = FootballPalette.headline(22)
        previewTitleLabel.textColor = FootballPalette.textPrimary
        previewTitleLabel.text = LineupStore.shared.currentLineup.title

        templateStack.axis = .horizontal
        templateStack.spacing = Spacing.s12
        templateStack.distribution = .fillEqually

        let poster = makeTemplateChip(L10n.Football.Export.matchPoster, selected: true)
        let social = makeTemplateChip(L10n.Football.Export.social, selected: false)
        templateStack.addArrangedSubview(poster)
        templateStack.addArrangedSubview(social)

        previewCard.showsNeonBorder = true
        previewCard.addSubview(previewPitch)
        previewCard.addSubview(previewTitleLabel)

        downloadButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)

        view.addSubview(previewCard)
        view.addSubview(templateStack)
        view.addSubview(downloadButton)
        view.addSubview(shareButton)

        previewCard.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.s20)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
        }
        previewPitch.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(Spacing.s16)
            make.height.equalTo(280)
        }
        previewTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(previewPitch.snp.bottom).offset(Spacing.s12)
            make.leading.trailing.bottom.equalToSuperview().inset(Spacing.s16)
        }
        templateStack.snp.makeConstraints { make in
            make.top.equalTo(previewCard.snp.bottom).offset(Spacing.s24)
            make.leading.trailing.equalTo(previewCard)
            make.height.equalTo(44)
        }
        downloadButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(previewCard)
            make.bottom.equalTo(shareButton.snp.top).offset(-Spacing.s12)
        }
        shareButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(previewCard)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Spacing.s20)
        }

        renderPreviewTokens()
    }

    override func refreshLocalization() {
        title = L10n.Football.Export.title
        downloadButton.setTitle(L10n.Football.Export.download, for: .normal)
        shareButton.setTitle(L10n.Football.Export.share, for: .normal)
    }

    private func makeTemplateChip(_ title: String, selected: Bool) -> UIView {
        let chip = FootballGlassView()
        chip.showsNeonBorder = selected
        let label = UILabel()
        label.text = title
        label.font = FootballPalette.caption()
        label.textColor = FootballPalette.textPrimary
        label.textAlignment = .center
        chip.addSubview(label)
        label.snp.makeConstraints { $0.edges.equalToSuperview().inset(Spacing.s12) }
        return chip
    }

    private func renderPreviewTokens() {
        let lineup = LineupStore.shared.currentLineup
        for assignment in lineup.assignments {
            let token = FootballPlayerTokenView(slotIndex: assignment.slotIndex, player: assignment.player)
            token.normalizedPosition = assignment.normalizedPosition
            token.isUserInteractionEnabled = false
            previewPitch.addSubview(token)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let tokens = previewPitch.subviews.compactMap { $0 as? FootballPlayerTokenView }
        let lineup = LineupStore.shared.currentLineup
        PitchPlayerTokenLayout.layout(tokens, formation: lineup.formation, in: previewPitch)
    }

    @objc private func shareTapped() {
        let renderer = UIGraphicsImageRenderer(bounds: previewCard.bounds)
        let image = renderer.image { ctx in
            previewCard.layer.render(in: ctx.cgContext)
        }
        let text = L10n.Football.Export.saved
        viewModel.presentSuccess(text)
        let activity = UIActivityViewController(
            activityItems: [image, LineupStore.shared.currentLineup.title],
            applicationActivities: nil
        )
        present(activity, animated: true)
    }
}
