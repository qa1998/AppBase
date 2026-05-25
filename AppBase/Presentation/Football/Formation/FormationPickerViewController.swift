//
//  FormationPickerViewController.swift
//  AppBase
//

import Combine
import SnapKit
import UIKit

/// Bottom sheet — filter by player count, tap formation to apply immediately.
final class FormationPickerViewController: UIViewController, FootballChromeRefreshable {

    private var chromeCancel = Set<AnyCancellable>()

    var onSelect: ((FootballFormation) -> Void)?

    private var selectedFormationId: String
    private var playerCount: Int

    private let headerBar = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let countScroll = UIScrollView()
    private let countStack = UIStackView()
    private var countButtons: [PlayerCountChip] = []
    private let collectionView: UICollectionView

    private var filteredFormations: [FootballFormation] = []

    init(selectedFormationId: String, playerCount: Int = 11) {
        self.playerCount = playerCount
        if FootballFormation.catalog.contains(where: { $0.id == selectedFormationId }) {
            self.selectedFormationId = selectedFormationId
        } else if let match = FootballFormation.catalog.first(where: { $0.name == selectedFormationId }) {
            self.selectedFormationId = match.id
        } else {
            self.selectedFormationId = FootballFormation.formations(playerCount: playerCount).first?.id
                ?? FootballFormation.default.id
        }
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Spacing.s12
        layout.minimumLineSpacing = Spacing.s12
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        installFootballChromeObservers(storage: &chromeCancel)
        setupSheet()
        buildHeader()
        buildPlayerCountFilter()
        buildCollection()
        layoutViews()
        refreshFootballAppearance()
        reloadFilteredFormations()
    }

    func refreshFootballLocalization() {
        titleLabel.text = L10n.Football.Formation.title
        countButtons.forEach { $0.refreshTitle() }
        collectionView.reloadData()
    }

    func refreshFootballAppearance() {
        view.backgroundColor = FootballPalette.background
        titleLabel.textColor = FootballPalette.textPrimary
        closeButton.tintColor = FootballPalette.textPrimary
        refreshFootballLocalization()
    }

    private func setupSheet() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = Radius.s20
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
    }

    private func buildHeader() {
        titleLabel.font = FootballPalette.title(18)
        titleLabel.textColor = FootballPalette.textPrimary

        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = FootballPalette.textPrimary
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        headerBar.addSubview(titleLabel)
        headerBar.addSubview(closeButton)
        view.addSubview(headerBar)
    }

    private func buildPlayerCountFilter() {
        countStack.axis = .horizontal
        countStack.spacing = Spacing.s16
        countScroll.showsHorizontalScrollIndicator = false
        countScroll.addSubview(countStack)
        countStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        countButtons = FormationCatalog.playerCounts.map { count in
            let chip = PlayerCountChip(count: count)
            chip.addTarget(self, action: #selector(countTapped(_:)), for: .touchUpInside)
            countStack.addArrangedSubview(chip)
            return chip
        }
        syncCountSelection()
        view.addSubview(countScroll)
    }

    private func buildCollection() {
        collectionView.backgroundColor = .clear
        collectionView.register(FormationGridCell.self, forCellWithReuseIdentifier: FormationGridCell.reuseId)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
    }

    private func layoutViews() {
        headerBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.s8)
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.height.equalTo(44)
        }
        titleLabel.snp.makeConstraints { $0.leading.centerY.equalToSuperview() }
        closeButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.size.equalTo(36)
        }
        countScroll.snp.makeConstraints { make in
            make.top.equalTo(headerBar.snp.bottom).offset(Spacing.s16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(countScroll.snp.bottom).offset(Spacing.s16)
            make.leading.trailing.equalToSuperview().inset(Spacing.s16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func reloadFilteredFormations() {
        filteredFormations = FootballFormation.formations(playerCount: playerCount)
        if !filteredFormations.contains(where: { $0.id == selectedFormationId }),
           let first = filteredFormations.first {
            selectedFormationId = first.id
        }
        collectionView.reloadData()
    }

    private func syncCountSelection() {
        countButtons.forEach { $0.isSelected = $0.count == playerCount }
    }

    private func applyAndDismiss(_ formation: FootballFormation) {
        onSelect?(formation)
        dismiss(animated: true)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func countTapped(_ sender: PlayerCountChip) {
        playerCount = sender.count
        syncCountSelection()
        reloadFilteredFormations()
    }
}

// MARK: - Collection

extension FormationPickerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredFormations.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FormationGridCell.reuseId,
            for: indexPath
        ) as! FormationGridCell
        let formation = filteredFormations[indexPath.item]
        cell.configure(
            formation: formation,
            isSelected: formation.id == selectedFormationId,
            isFavorite: FormationFavoritesStore.shared.isFavorite(formation.id)
        )
        cell.onFavoriteTap = { [weak self] in
            FormationFavoritesStore.shared.toggleFavorite(formation.id)
            self?.collectionView.reloadItems(at: [indexPath])
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let formation = filteredFormations[indexPath.item]
        applyAndDismiss(formation)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.bounds.width - Spacing.s12) / 2
        return CGSize(width: width, height: 130)
    }
}

// MARK: - Player count chip

private final class PlayerCountChip: UIControl {

    let count: Int
    private let label = UILabel()

    override var isSelected: Bool {
        didSet { updateStyle() }
    }

    init(count: Int) {
        self.count = count
        super.init(frame: .zero)
        refreshTitle()
        label.font = FootballPalette.title(16)
        label.textAlignment = .center
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(40)
        }
        updateStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refreshTitle() {
        label.text = L10n.Football.Match.Create.pitchPlayers(count)
    }

    private func updateStyle() {
        if isSelected {
            backgroundColor = FootballPalette.accentRed
            label.textColor = FootballPalette.onAccent
            layer.cornerRadius = 20
        } else {
            backgroundColor = .clear
            label.textColor = FootballPalette.textSecondary
            layer.cornerRadius = 0
        }
    }
}

// MARK: - Formation cell

private final class FormationGridCell: UICollectionViewCell {

    static let reuseId = "FormationGridCell"

    var onFavoriteTap: (() -> Void)?

    private let card = UIView()
    private let borderView = UIView()
    private let favoriteButton = UIButton(type: .system)
    private let preview = FootballFormationPreviewView(formation: .default)
    private let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        card.backgroundColor = FootballPalette.surface
        card.layer.cornerRadius = Radius.s12
        borderView.layer.cornerRadius = Radius.s12
        borderView.layer.borderWidth = 2
        borderView.isUserInteractionEnabled = false
        favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteButton.tintColor = FootballPalette.accentRed
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        nameLabel.font = FootballPalette.caption(13)
        nameLabel.textColor = FootballPalette.textPrimary
        nameLabel.textAlignment = .center
        contentView.addSubview(borderView)
        contentView.addSubview(card)
        card.addSubview(favoriteButton)
        card.addSubview(preview)
        card.addSubview(nameLabel)
        borderView.snp.makeConstraints { $0.edges.equalToSuperview() }
        card.snp.makeConstraints { $0.edges.equalToSuperview().inset(2) }
        favoriteButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Spacing.s8)
            make.size.equalTo(28)
        }
        preview.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.s28)
            make.leading.trailing.equalToSuperview().inset(Spacing.s10)
            make.height.equalTo(64)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(preview.snp.bottom).offset(Spacing.s6)
            make.leading.trailing.bottom.equalToSuperview().inset(Spacing.s8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(formation: FootballFormation, isSelected: Bool, isFavorite: Bool) {
        nameLabel.text = formation.name
        nameLabel.textColor = FootballPalette.textPrimary
        card.backgroundColor = FootballPalette.surface
        preview.formation = formation
        let star = isFavorite ? "star.fill" : "star"
        favoriteButton.setImage(UIImage(systemName: star), for: .normal)
        favoriteButton.tintColor = FootballPalette.accentRed
        borderView.layer.borderColor = isSelected
            ? FootballPalette.accentGreen.cgColor
            : UIColor.clear.cgColor
        borderView.layer.borderWidth = isSelected ? 2 : 0
    }

    @objc private func favoriteTapped() {
        onFavoriteTap?()
    }
}
