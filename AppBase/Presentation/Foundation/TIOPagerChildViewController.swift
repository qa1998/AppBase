//
//  TIOPagerChildViewController.swift
//  AppBase
//

import BaseMVVM
import JXSegmentedView
import UIKit

/// Trang con cho `TIOPagerViewController`.
///
/// Chỉ cần kế thừa và build UI như `TIOViewController` bình thường, pager sẽ tự quản lý lifecycle.
class TIOPagerChildViewController<VM: TIOViewModel<TIOLoadingTarget>>: TIOViewController<VM, TIOLoadingTarget>,
    JXSegmentedListContainerViewListDelegate {

    // MARK: - JXSegmentedListContainerViewListDelegate

    public func listView() -> UIView {
        view
    }
}

typealias TIOPagerChildScreenViewController<VM> = TIOPagerChildViewController<VM> where VM: TIOViewModel<TIOLoadingTarget>

