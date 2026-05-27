//
//  TIOPagerViewController.swift
//  AppBase
//

import BaseMVVM
import Combine
import JXSegmentedView
import SnapKit
import UIKit

/// Tab + pager dựa trên `JXSegmentedView` + `JXSegmentedListContainerView`.
///
/// Subclass cần override:
/// - `pagerTitles`
/// - `makePage(at:)`
///
/// Nếu titles đổi theo ngôn ngữ/data → gọi `reloadPager()`.
class TIOPagerViewController<VM: TIOViewModel<TIOLoadingTarget>>: TIOViewController<VM, TIOLoadingTarget>, JXSegmentedListContainerViewDataSource {

    // MARK: - Views

    let pagerContainerView = TIOContentView()

    private(set) lazy var segmentedView: JXSegmentedView = {
        let view = JXSegmentedView()
        view.delegate = self
        return view
    }()

    /// DataSource phải được strong-reference, nếu không sẽ bị release.
    private(set) lazy var segmentedDataSource: JXSegmentedTitleDataSource = {
        let ds = JXSegmentedTitleDataSource()
        return ds
    }()

    private(set) lazy var listContainerView: JXSegmentedListContainerView = {
        let view = JXSegmentedListContainerView(dataSource: self)
        return view
    }()

    private var indicatorLineView: JXSegmentedIndicatorLineView?

    // MARK: - Configuration (override)

    /// Titles của tab. Sau khi thay đổi, gọi `reloadPager()`.
    var pagerTitles: [String] { [] }

    var defaultPageIndex: Int { 0 }

    var pagerStyle: TIOPagerStyle { .default }

    /// Factory trang con. Trả về VC/View conform `JXSegmentedListContainerViewListDelegate`.
    func makePage(at index: Int) -> JXSegmentedListContainerViewListDelegate {
        fatalError("Subclass must override makePage(at:)")
    }

    // MARK: - Hooks

    func pagerDidSelect(index: Int) {}
    func pagerDidClickSelect(index: Int) {}
    func pagerDidScrollSelect(index: Int) {}

    // MARK: - Overrides

    override var shimmerContentView: UIView {
        pagerContainerView
    }

    /// `false` khi subclass tự gắn `segmentedView` / `listContainerView` (ví dụ sticky header).
    open var usesDefaultPagerLayout: Bool { true }

    override func setupUI() {
        super.setupUI()
        if usesDefaultPagerLayout {
            setupPagerUI()
        } else {
            applyPagerTheme(ThemeManager.shared.palette)
        }
        reloadPager()
    }

    /// Gắn pager vào container tùy chỉnh (segment bar + nội dung list).
    open func installPager(segmentContainer: UIView, listContainer: UIView) {
        if segmentedView.superview !== segmentContainer {
            segmentedView.removeFromSuperview()
            segmentContainer.addSubview(segmentedView)
        }
        segmentedView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(pagerStyle.barHeight)
        }

        if listContainerView.superview !== listContainer {
            listContainerView.removeFromSuperview()
            listContainer.addSubview(listContainerView)
        }
        listContainerView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }

        segmentedView.listContainer = listContainerView
        segmentedView.contentEdgeInsetLeft = pagerStyle.contentEdgeInsetLeft
        segmentedView.contentEdgeInsetRight = pagerStyle.contentEdgeInsetRight
    }

    override func applyScreenTheme(_ colors: ThemeColors) {
        super.applyScreenTheme(colors)
        applyPagerTheme(colors)
    }

    override func refreshLocalization() {
        super.refreshLocalization()
        reloadPager()
    }

    // MARK: - Public

    var selectedPageIndex: Int {
        segmentedView.selectedIndex
    }

    func selectPage(at index: Int) {
        guard index >= 0, index < pagerTitles.count else { return }
        segmentedView.selectItemAt(index: index)
    }

    func reloadPager() {
        let titles = pagerTitles
        let selectedIndex = clampedDefaultIndex(for: titles.count)

        segmentedDataSource.titles = titles
        segmentedDataSource.reloadData(selectedIndex: selectedIndex)
        segmentedView.dataSource = segmentedDataSource
        segmentedView.defaultSelectedIndex = selectedIndex
        segmentedView.reloadData()

        listContainerView.defaultSelectedIndex = selectedIndex
        listContainerView.reloadData()

        // Disable horizontal scroll if single tab.
        listContainerView.scrollView.isScrollEnabled = titles.count > 1
    }

    // MARK: - Setup helpers

    private func setupPagerUI() {
        view.addSubview(pagerContainerView)
        pagerContainerView.addSubview(segmentedView)
        pagerContainerView.addSubview(listContainerView)

        pagerContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        segmentedView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(pagerStyle.barHeight)
        }

        listContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentedView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        segmentedView.listContainer = listContainerView
        segmentedView.contentEdgeInsetLeft = pagerStyle.contentEdgeInsetLeft
        segmentedView.contentEdgeInsetRight = pagerStyle.contentEdgeInsetRight

        applyPagerTheme(ThemeManager.shared.palette)
    }

    func applyPagerTheme(_ colors: ThemeColors) {
        let style = pagerStyle

        pagerContainerView.backgroundColor = style.contentBackgroundColor ?? colors.backgroundSecondary
        segmentedView.backgroundColor = style.barBackgroundColor ?? colors.backgroundSecondary

        segmentedDataSource.titleNormalColor = style.titleColor ?? colors.textSecondary
        segmentedDataSource.titleSelectedColor = style.selectedTitleColor ?? colors.primary
        segmentedDataSource.titleNormalFont = style.titleFont
        segmentedDataSource.titleSelectedFont = style.selectedTitleFont
        segmentedDataSource.isTitleColorGradientEnabled = style.isTitleColorGradientEnabled
        segmentedDataSource.itemSpacing = style.itemSpacing
        segmentedDataSource.isItemSpacingAverageEnabled = style.isItemSpacingAverageEnabled

        if style.showsIndicatorLine {
            let line = indicatorLineView ?? JXSegmentedIndicatorLineView()
            line.indicatorColor = style.indicatorColor ?? colors.primary
            line.indicatorWidth = style.indicatorWidth
            line.indicatorHeight = style.indicatorLineHeight
            // Similar to "lengthen" style from JXCategoryView
            line.lineStyle = .lengthen
            indicatorLineView = line
            segmentedView.indicators = [line]
        } else {
            indicatorLineView = nil
            segmentedView.indicators = []
        }

        segmentedView.reloadData()
    }

    private func clampedDefaultIndex(for count: Int) -> Int {
        guard count > 0 else { return 0 }
        return min(max(defaultPageIndex, 0), count - 1)
    }

    // MARK: - JXSegmentedListContainerViewDataSource (@objc)

    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        pagerTitles.count
    }

    func listContainerView(
        _ listContainerView: JXSegmentedListContainerView,
        initListAt index: Int
    ) -> JXSegmentedListContainerViewListDelegate {
        makePage(at: index)
    }
}

// MARK: - JXSegmentedViewDelegate

extension TIOPagerViewController: JXSegmentedViewDelegate {
    public func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        pagerDidSelect(index: index)
    }

    public func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        pagerDidClickSelect(index: index)
    }

    public func segmentedView(_ segmentedView: JXSegmentedView, didScrollSelectedItemAt index: Int) {
        pagerDidScrollSelect(index: index)
    }
}

typealias TIOPagerScreenViewController<VM> = TIOPagerViewController<VM> where VM: TIOViewModel<TIOLoadingTarget>

