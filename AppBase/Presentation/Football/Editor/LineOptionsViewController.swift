//
//  LineOptionsViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import SnapKit
import UIKit

/// Bottom sheet — solid/dashed, straight/curved, pointer, color for tactical lines.
final class LineOptionsViewController: FootballScreenViewController<LineOptionsViewModel> {

    var onSave: ((TacticalLineOptions) -> Void)?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let headerBar = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let styleSegment = UISegmentedControl()
    private let straightRow = LineOptionChoiceRow()
    private let curvedRow = LineOptionChoiceRow()
    private let pointerGrid = UIStackView()
    private var pointerButtons: [LinePointerOptionButton] = []
    private let colorStack = UIStackView()
    private var colorButtons: [LineColorOptionButton] = []
    private let saveButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSheet()
    }

    override func setupUI() {
        super.setupUI()
        buildUI()
        layoutViews()
        syncUI()
    }

    override func refreshLocalization() {
        titleLabel.text = L10n.Football.LineOptions.title
        styleSegment.setTitle(L10n.Football.LineOptions.solid, forSegmentAt: 0)
        styleSegment.setTitle(L10n.Football.LineOptions.dashed, forSegmentAt: 1)
        saveButton.setTitle(L10n.Football.LineOptions.save, for: .normal)
        syncUI()
    }

    override func onBind() {
        super.onBind()
        viewModel.$draft
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.syncUI()
            }
            .store(in: &cancelBag)
    }

    private func setupSheet() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = Radius.s20
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
    }

    private func buildUI() {
        view.backgroundColor = FootballPalette.background

        titleLabel.font = FootballPalette.title(18)
        titleLabel.textColor = FootballPalette.textPrimary

        closeButton.setImage(
            UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)),
            for: .normal
        )
        closeButton.tintColor = FootballPalette.textPrimary
        closeButton.backgroundColor = FootballPalette.surface
        closeButton.layer.cornerRadius = 18
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        headerBar.addSubview(titleLabel)
        headerBar.addSubview(closeButton)

        configureStyleSegment()

        straightRow.addTarget(self, action: #selector(straightTapped), for: .touchUpInside)
        curvedRow.addTarget(self, action: #selector(curvedTapped), for: .touchUpInside)

        pointerGrid.axis = .vertical
        pointerGrid.spacing = Spacing.s10
        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.distribution = .fillEqually
        row1.spacing = Spacing.s10
        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.distribution = .fillEqually
        row2.spacing = Spacing.s10
        pointerGrid.addArrangedSubview(row1)
        pointerGrid.addArrangedSubview(row2)

        TacticalLinePointer.allCases.forEach { pointer in
            let button = LinePointerOptionButton(pointer: pointer)
            button.addTarget(self, action: #selector(pointerTapped(_:)), for: .touchUpInside)
            pointerButtons.append(button)
            if pointerButtons.count <= 3 {
                row1.addArrangedSubview(button)
            } else {
                row2.addArrangedSubview(button)
            }
        }

        colorStack.axis = .horizontal
        colorStack.spacing = Spacing.s16
        colorStack.alignment = .center
        colorStack.distribution = .equalSpacing
        TacticalLineColor.allCases.forEach { color in
            let button = LineColorOptionButton(color: color)
            button.addTarget(self, action: #selector(colorTapped(_:)), for: .touchUpInside)
            colorButtons.append(button)
            colorStack.addArrangedSubview(button)
        }

        saveButton.setTitleColor(FootballPalette.onAccent, for: .normal)
        saveButton.titleLabel?.font = FootballPalette.title(16)
        saveButton.backgroundColor = FootballPalette.accentRed
        saveButton.layer.cornerRadius = Radius.s12
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        contentStack.axis = .vertical
        contentStack.spacing = Spacing.s16
        contentStack.addArrangedSubview(styleSegment)
        contentStack.addArrangedSubview(sectionLabel(L10n.Football.LineOptions.lineType))
        contentStack.addArrangedSubview(straightRow)
        contentStack.addArrangedSubview(curvedRow)
        contentStack.addArrangedSubview(sectionLabel(L10n.Football.LineOptions.pointer))
        contentStack.addArrangedSubview(pointerGrid)
        contentStack.addArrangedSubview(sectionLabel(L10n.Football.LineOptions.color))
        contentStack.addArrangedSubview(colorStack)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.addSubview(contentStack)
        view.addSubview(headerBar)
        view.addSubview(scrollView)
        view.addSubview(saveButton)

        refreshLocalization()
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

        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.s20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Spacing.s16)
            make.height.equalTo(52)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerBar.snp.bottom).offset(Spacing.s12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(saveButton.snp.top).offset(-Spacing.s16)
        }

        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(
                top: 0,
                left: Spacing.s20,
                bottom: Spacing.s20,
                right: Spacing.s20
            ))
            make.width.equalTo(scrollView).offset(-Spacing.s40)
        }

        styleSegment.snp.makeConstraints { $0.height.equalTo(44) }
        [straightRow, curvedRow].forEach { $0.snp.makeConstraints { $0.height.equalTo(56) } }
        pointerButtons.forEach { $0.snp.makeConstraints { $0.height.equalTo(60) } }
    }

    private func sectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = FootballPalette.caption(13)
        label.textColor = FootballPalette.textSecondary
        return label
    }

    private func configureStyleSegment() {
        styleSegment.removeAllSegments()
        styleSegment.insertSegment(withTitle: L10n.Football.LineOptions.solid, at: 0, animated: false)
        styleSegment.insertSegment(withTitle: L10n.Football.LineOptions.dashed, at: 1, animated: false)
        styleSegment.selectedSegmentIndex = 0
        styleSegment.backgroundColor = FootballPalette.surface
        styleSegment.selectedSegmentTintColor = FootballPalette.surfaceElevated
        styleSegment.setTitleTextAttributes(
            [
                .foregroundColor: FootballPalette.textPrimary,
                .font: FootballPalette.title(15),
            ],
            for: .selected
        )
        styleSegment.setTitleTextAttributes(
            [
                .foregroundColor: FootballPalette.textSecondary,
                .font: FootballPalette.title(15),
            ],
            for: .normal
        )
        styleSegment.addTarget(self, action: #selector(styleSegmentChanged), for: .valueChanged)
    }

    private func syncUI() {
        let draft = viewModel.draft
        let segmentIndex = draft.lineStyle == .solid ? 0 : 1
        if styleSegment.selectedSegmentIndex != segmentIndex {
            styleSegment.selectedSegmentIndex = segmentIndex
        }
        applyLineStyleToDependentViews(dashed: draft.lineStyle == .dashed)
        straightRow.isSelected = draft.pathType == .straight
        curvedRow.isSelected = draft.pathType == .curved
        pointerButtons.forEach { $0.isSelected = $0.pointer == draft.pointer }
        colorButtons.forEach { $0.isSelected = $0.lineColor == draft.color }
    }

    /// Cập nhật preview line type + pointer khi đổi Solid / Dashed.
    private func applyLineStyleToDependentViews(dashed: Bool) {
        straightRow.configure(preview: .straight(dashed: dashed))
        curvedRow.configure(preview: .curved(dashed: dashed))
        pointerButtons.forEach { $0.applyLineStyle(dashed: dashed) }
    }

    @objc private func styleSegmentChanged() {
        let style: TacticalLineStyle = styleSegment.selectedSegmentIndex == 0 ? .solid : .dashed
        viewModel.mutateDraft { $0.lineStyle = style }
        applyLineStyleToDependentViews(dashed: style == .dashed)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func straightTapped() {
        viewModel.mutateDraft { $0.pathType = .straight }
    }

    @objc private func curvedTapped() {
        viewModel.mutateDraft { $0.pathType = .curved }
    }

    @objc private func pointerTapped(_ sender: LinePointerOptionButton) {
        viewModel.mutateDraft { $0.pointer = sender.pointer }
    }

    @objc private func colorTapped(_ sender: LineColorOptionButton) {
        viewModel.mutateDraft { $0.color = sender.lineColor }
    }

    @objc private func saveTapped() {
        onSave?(viewModel.draft)
        dismiss(animated: true)
    }
}

// MARK: - Line type row

private enum LinePreviewStyle {
    case straight(dashed: Bool)
    case curved(dashed: Bool)
}

private final class LineOptionChoiceRow: UIControl {

    private let radioView = UIView()
    private let radioInner = UIView()
    private let previewView = LinePreviewView()
    private let chevronView = UIImageView()

    override var isSelected: Bool {
        didSet { updateSelection() }
    }

    func configure(preview: LinePreviewStyle) {
        switch preview {
        case .straight(let dashed):
            previewView.style = .straight
            previewView.isDashed = dashed
        case .curved(let dashed):
            previewView.style = .curved
            previewView.isDashed = dashed
        }
        previewView.setNeedsDisplay()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = FootballPalette.surface
        layer.cornerRadius = Radius.s12

        radioView.layer.cornerRadius = 11
        radioView.layer.borderWidth = 2
        radioInner.layer.cornerRadius = 5
        radioInner.backgroundColor = FootballPalette.accentGreen
        radioInner.isHidden = true
        radioView.addSubview(radioInner)
        radioInner.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(10)
        }

        previewView.strokeColor = .white

        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        chevronView.image = UIImage(systemName: "chevron.right", withConfiguration: chevronConfig)
        chevronView.tintColor = FootballPalette.textSecondary
        chevronView.contentMode = .scaleAspectFit

        addSubview(radioView)
        addSubview(previewView)
        addSubview(chevronView)

        radioView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.s16)
            make.centerY.equalToSuperview()
            make.size.equalTo(22)
        }
        chevronView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Spacing.s16)
            make.centerY.equalToSuperview()
            make.size.equalTo(18)
        }
        previewView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(32)
        }
        updateSelection()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateSelection() {
        let active = isSelected
        layer.borderWidth = active ? 2 : 0
        layer.borderColor = FootballPalette.accentGreen.cgColor
        radioView.layer.borderColor = (active ? FootballPalette.accentGreen : FootballPalette.textSecondary)
            .withAlphaComponent(active ? 1 : 0.35).cgColor
        radioInner.isHidden = !active
    }
}

private final class LinePreviewView: UIView {

    enum Style { case straight, curved }

    var style: Style = .straight
    var isDashed = false
    var strokeColor: UIColor = .white

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.setStrokeColor(strokeColor.cgColor)
        ctx.setLineWidth(2.5)
        ctx.setLineCap(.round)
        if isDashed {
            ctx.setLineDash(phase: 0, lengths: [6, 5])
        }
        let inset = rect.insetBy(dx: 8, dy: rect.height * 0.32)
        ctx.beginPath()
        ctx.move(to: CGPoint(x: inset.minX, y: inset.midY))
        switch style {
        case .straight:
            ctx.addLine(to: CGPoint(x: inset.maxX, y: inset.midY))
        case .curved:
            ctx.addQuadCurve(
                to: CGPoint(x: inset.maxX, y: inset.midY),
                control: CGPoint(x: inset.midX, y: inset.minY - 8)
            )
        }
        ctx.strokePath()
    }
}

// MARK: - Pointer grid

private extension TacticalLinePointer {

    /// Asset name when preview images are added to the catalog (e.g. `ic-line-pointer-arrow`).
    var previewImageName: String? {
        "ic-line-pointer-\(rawValue)"
    }
}

private final class LinePointerOptionButton: UIControl {

    let pointer: TacticalLinePointer
    private let iconView = UIImageView()
    private let preview = LinePointerPreviewView()

    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected ? 2 : 0
            layer.borderColor = FootballPalette.accentGreen.cgColor
        }
    }

    func applyLineStyle(dashed: Bool) {
        isDashed = dashed
        reloadPreviewContent()
    }

    private var isDashed = false

    init(pointer: TacticalLinePointer) {
        self.pointer = pointer
        super.init(frame: .zero)
        backgroundColor = FootballPalette.surface
        layer.cornerRadius = Radius.s12

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .white

        preview.pointer = pointer
        preview.strokeColor = .white

        addSubview(iconView)
        addSubview(preview)
        reloadPreviewContent()

        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.65)
            make.height.equalTo(24)
        }
        preview.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(24)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func reloadPreviewContent() {
        preview.isDashed = isDashed
        if let name = pointer.previewImageName, let image = UIImage(named: name) {
            iconView.image = image.withRenderingMode(.alwaysTemplate)
            iconView.isHidden = false
            preview.isHidden = true
        } else {
            iconView.isHidden = true
            preview.isHidden = false
            preview.setNeedsDisplay()
        }
    }
}

private final class LinePointerPreviewView: UIView {

    var pointer: TacticalLinePointer = .arrow
    var strokeColor: UIColor = .white
    var isDashed = false

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.setStrokeColor(strokeColor.cgColor)
        ctx.setLineWidth(2.5)
        ctx.setLineCap(.round)
        if isDashed {
            ctx.setLineDash(phase: 0, lengths: [4, 3])
        }
        let y = rect.midY
        let start = CGPoint(x: rect.minX + 4, y: y)
        let end = CGPoint(x: rect.maxX - 10, y: y)
        ctx.beginPath()
        ctx.move(to: start)
        ctx.addLine(to: end)
        ctx.strokePath()

        switch pointer {
        case .arrow:
            drawArrow(ctx: ctx, from: CGPoint(x: end.x - 14, y: y), to: end, filled: true)
        case .hollowArrow:
            drawArrow(ctx: ctx, from: CGPoint(x: end.x - 14, y: y), to: end, filled: false)
        case .diamond:
            let s: CGFloat = 6
            ctx.move(to: CGPoint(x: end.x, y: end.y - s))
            ctx.addLine(to: CGPoint(x: end.x + s, y: end.y))
            ctx.addLine(to: CGPoint(x: end.x, y: end.y + s))
            ctx.addLine(to: CGPoint(x: end.x - s, y: end.y))
            ctx.closePath()
            ctx.strokePath()
        case .bar:
            ctx.move(to: CGPoint(x: end.x, y: end.y - 7))
            ctx.addLine(to: CGPoint(x: end.x, y: end.y + 7))
            ctx.strokePath()
        case .cross:
            ctx.move(to: CGPoint(x: end.x - 5, y: end.y - 5))
            ctx.addLine(to: CGPoint(x: end.x + 5, y: end.y + 5))
            ctx.move(to: CGPoint(x: end.x + 5, y: end.y - 5))
            ctx.addLine(to: CGPoint(x: end.x - 5, y: end.y + 5))
            ctx.strokePath()
        case .none:
            break
        }
    }

    private func drawArrow(ctx: CGContext, from: CGPoint, to: CGPoint, filled: Bool) {
        let angle = atan2(to.y - from.y, to.x - from.x)
        let size: CGFloat = 7
        let p1 = CGPoint(
            x: to.x - size * cos(angle - .pi / 6),
            y: to.y - size * sin(angle - .pi / 6)
        )
        let p2 = CGPoint(
            x: to.x - size * cos(angle + .pi / 6),
            y: to.y - size * sin(angle + .pi / 6)
        )
        ctx.move(to: to)
        ctx.addLine(to: p1)
        ctx.move(to: to)
        ctx.addLine(to: p2)
        ctx.strokePath()
        if filled {
            ctx.move(to: to)
            ctx.addLine(to: p1)
            ctx.addLine(to: p2)
            ctx.closePath()
            ctx.setFillColor(strokeColor.cgColor)
            ctx.fillPath()
        }
    }
}

// MARK: - Color swatches

private final class LineColorOptionButton: UIControl {

    let lineColor: TacticalLineColor
    private let ringView = UIView()
    private let swatchView = UIView()

    override var isSelected: Bool {
        didSet {
            ringView.layer.borderWidth = isSelected ? 3 : 0
            ringView.layer.borderColor = FootballPalette.accentGreen.cgColor
        }
    }

    init(color: TacticalLineColor) {
        lineColor = color
        super.init(frame: .zero)
        swatchView.backgroundColor = color.uiColor
        swatchView.layer.cornerRadius = 16
        swatchView.isUserInteractionEnabled = false
        ringView.layer.cornerRadius = 20
        ringView.isUserInteractionEnabled = false
        addSubview(ringView)
        addSubview(swatchView)
        ringView.snp.makeConstraints { $0.edges.equalToSuperview() }
        swatchView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(32)
        }
        snp.makeConstraints { $0.size.equalTo(40) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
