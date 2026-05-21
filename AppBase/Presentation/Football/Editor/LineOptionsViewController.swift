//
//  LineOptionsViewController.swift
//  AppBase
//

import SnapKit
import UIKit

/// Bottom sheet — solid/dashed, straight/curved, pointer, color for tactical lines.
final class LineOptionsViewController: UIViewController {

    var onSave: ((TacticalLineOptions) -> Void)?

    private var draft: TacticalLineOptions

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

    init(options: TacticalLineOptions = LineupStore.shared.tacticalLineOptions) {
        draft = options
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = FootballPalette.background
        setupSheet()
        buildUI()
        layoutViews()
        syncUI()
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
        titleLabel.text = L10n.Football.LineOptions.title
        titleLabel.font = FootballPalette.title(18)
        titleLabel.textColor = FootballPalette.textPrimary

        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = FootballPalette.textPrimary
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        headerBar.addSubview(titleLabel)
        headerBar.addSubview(closeButton)

        styleSegment.insertSegment(withTitle: L10n.Football.LineOptions.solid, at: 0, animated: false)
        styleSegment.insertSegment(withTitle: L10n.Football.LineOptions.dashed, at: 1, animated: false)
        styleSegment.selectedSegmentIndex = 0
        styleSegment.backgroundColor = FootballPalette.surface
        styleSegment.selectedSegmentTintColor = FootballPalette.surfaceElevated
        styleSegment.setTitleTextAttributes(
            [.foregroundColor: FootballPalette.textPrimary, .font: FootballPalette.title(14)],
            for: .selected
        )
        styleSegment.setTitleTextAttributes(
            [.foregroundColor: FootballPalette.textSecondary, .font: FootballPalette.caption(14)],
            for: .normal
        )
        styleSegment.addTarget(self, action: #selector(styleChanged), for: .valueChanged)

        straightRow.configure(
            title: L10n.Football.LineOptions.straight,
            preview: .straight(dashed: false)
        )
        straightRow.addTarget(self, action: #selector(straightTapped), for: .touchUpInside)

        curvedRow.configure(
            title: L10n.Football.LineOptions.curved,
            preview: .curved(dashed: false)
        )
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
        colorStack.spacing = Spacing.s14
        colorStack.alignment = .center
        TacticalLineColor.allCases.forEach { color in
            let button = LineColorOptionButton(color: color)
            button.addTarget(self, action: #selector(colorTapped(_:)), for: .touchUpInside)
            colorButtons.append(button)
            colorStack.addArrangedSubview(button)
        }

        saveButton.setTitle(L10n.Football.LineOptions.save, for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = FootballPalette.title(16)
        saveButton.backgroundColor = FootballPalette.accentRed
        saveButton.layer.cornerRadius = Radius.s12
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        contentStack.axis = .vertical
        contentStack.spacing = Spacing.s20
        contentStack.addArrangedSubview(styleSegment)
        contentStack.addArrangedSubview(sectionLabel(L10n.Football.LineOptions.lineType))
        contentStack.addArrangedSubview(straightRow)
        contentStack.addArrangedSubview(curvedRow)
        contentStack.addArrangedSubview(sectionLabel(L10n.Football.LineOptions.pointer))
        contentStack.addArrangedSubview(pointerGrid)
        contentStack.addArrangedSubview(sectionLabel(L10n.Football.LineOptions.color))
        contentStack.addArrangedSubview(colorStack)

        scrollView.addSubview(contentStack)
        view.addSubview(headerBar)
        view.addSubview(scrollView)
        view.addSubview(saveButton)
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
        [straightRow, curvedRow].forEach { $0.snp.makeConstraints { $0.height.equalTo(52) } }
        pointerButtons.forEach { $0.snp.makeConstraints { $0.height.equalTo(56) } }
    }

    private func sectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = FootballPalette.caption()
        label.textColor = FootballPalette.textSecondary
        return label
    }

    private func syncUI() {
        styleSegment.selectedSegmentIndex = draft.lineStyle == .solid ? 0 : 1
        let dashed = draft.lineStyle == .dashed
        straightRow.configure(
            title: L10n.Football.LineOptions.straight,
            preview: .straight(dashed: dashed)
        )
        curvedRow.configure(
            title: L10n.Football.LineOptions.curved,
            preview: .curved(dashed: dashed)
        )
        straightRow.isSelected = draft.pathType == .straight
        curvedRow.isSelected = draft.pathType == .curved
        pointerButtons.forEach { $0.isSelected = $0.pointer == draft.pointer }
        colorButtons.forEach { $0.isSelected = $0.lineColor == draft.color }
        pointerButtons.forEach { $0.previewColor = draft.color.uiColor }
        pointerButtons.forEach { $0.isDashed = dashed }
        straightRow.previewColor = draft.color.uiColor
        curvedRow.previewColor = draft.color.uiColor
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func styleChanged() {
        draft.lineStyle = styleSegment.selectedSegmentIndex == 0 ? .solid : .dashed
        syncUI()
    }

    @objc private func straightTapped() {
        draft.pathType = .straight
        syncUI()
    }

    @objc private func curvedTapped() {
        draft.pathType = .curved
        syncUI()
    }

    @objc private func pointerTapped(_ sender: LinePointerOptionButton) {
        draft.pointer = sender.pointer
        syncUI()
    }

    @objc private func colorTapped(_ sender: LineColorOptionButton) {
        draft.color = sender.lineColor
        syncUI()
    }

    @objc private func saveTapped() {
        onSave?(draft)
        dismiss(animated: true)
    }
}

// MARK: - Row & option controls

private enum LinePreviewStyle {
    case straight(dashed: Bool)
    case curved(dashed: Bool)
}

private final class LineOptionChoiceRow: UIControl {

    private let radioView = UIView()
    private let radioInner = UIView()
    private let previewView = LinePreviewView()
    private let titleLabel = UILabel()

    override var isSelected: Bool {
        didSet { updateSelection() }
    }

    var previewColor: UIColor = FootballPalette.accentGreen {
        didSet { previewView.strokeColor = previewColor }
    }

    func configure(title: String, preview: LinePreviewStyle) {
        titleLabel.text = title
        switch preview {
        case .straight(let dashed):
            previewView.style = .straight
            previewView.isDashed = dashed
        case .curved(let dashed):
            previewView.style = .curved
            previewView.isDashed = dashed
        }
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

        titleLabel.font = FootballPalette.title(15)
        titleLabel.textColor = FootballPalette.textPrimary

        addSubview(radioView)
        addSubview(previewView)
        addSubview(titleLabel)

        radioView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.s16)
            make.centerY.equalToSuperview()
            make.size.equalTo(22)
        }
        previewView.snp.makeConstraints { make in
            make.leading.equalTo(radioView.snp.trailing).offset(Spacing.s16)
            make.centerY.equalToSuperview()
            make.width.equalTo(72)
            make.height.equalTo(28)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(previewView.snp.trailing).offset(Spacing.s12)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().inset(Spacing.s12)
        }
        updateSelection()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateSelection() {
        let active = isSelected
        radioView.layer.borderColor = (active ? FootballPalette.accentGreen : FootballPalette.textSecondary)
            .withAlphaComponent(active ? 1 : 0.4).cgColor
        radioInner.isHidden = !active
    }
}

private final class LinePreviewView: UIView {

    enum Style { case straight, curved }

    var style: Style = .straight
    var isDashed = false
    var strokeColor: UIColor = FootballPalette.accentGreen

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.setStrokeColor(strokeColor.cgColor)
        ctx.setLineWidth(2)
        ctx.setLineCap(.round)
        if isDashed {
            ctx.setLineDash(phase: 0, lengths: [5, 4])
        }
        let inset = rect.insetBy(dx: 4, dy: rect.height * 0.35)
        ctx.beginPath()
        ctx.move(to: CGPoint(x: inset.minX, y: inset.midY))
        switch style {
        case .straight:
            ctx.addLine(to: CGPoint(x: inset.maxX, y: inset.midY))
        case .curved:
            ctx.addQuadCurve(
                to: CGPoint(x: inset.maxX, y: inset.midY),
                control: CGPoint(x: inset.midX, y: inset.minY - 6)
            )
        }
        ctx.strokePath()
    }
}

private final class LinePointerOptionButton: UIControl {

    let pointer: TacticalLinePointer
    private let preview = LinePointerPreviewView()

    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected ? 2 : 0
            layer.borderColor = FootballPalette.accentGreen.cgColor
        }
    }

    var previewColor: UIColor = FootballPalette.accentGreen {
        didSet { preview.strokeColor = previewColor }
    }

    var isDashed = false {
        didSet { preview.isDashed = isDashed }
    }

    init(pointer: TacticalLinePointer) {
        self.pointer = pointer
        super.init(frame: .zero)
        backgroundColor = FootballPalette.surface
        layer.cornerRadius = Radius.s12
        preview.pointer = pointer
        addSubview(preview)
        preview.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalTo(20)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class LinePointerPreviewView: UIView {

    var pointer: TacticalLinePointer = .arrow
    var strokeColor: UIColor = FootballPalette.accentGreen
    var isDashed = false

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.setStrokeColor(strokeColor.cgColor)
        ctx.setLineWidth(2)
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

private final class LineColorOptionButton: UIControl {

    let lineColor: TacticalLineColor
    private let ringView = UIView()
    private let swatchView = UIView()

    override var isSelected: Bool {
        didSet {
            ringView.layer.borderWidth = isSelected ? 3 : 0
            ringView.layer.borderColor = UIColor.white.cgColor
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
