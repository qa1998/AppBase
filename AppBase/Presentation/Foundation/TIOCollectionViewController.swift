//
//  TIOCollectionViewController.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import TIOPagingKit
import UIKit
import BaseMVVM

class TIOCollectionViewController<VM: TIOListViewModel>: TIOListViewController<VM>,
                                                       UICollectionViewDelegate,
                                                       UICollectionViewDataSource,
                                                       UICollectionViewDelegateFlowLayout {

    lazy var collectionView: TIOPagingCollectionView = {
        let collectionView = TIOPagingCollectionView(
            frame: .zero,
            collectionViewLayout: createCollectionViewLayout()
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    override func createListView() -> any TIOListView {
        return collectionView
    }

    override func setupUI() {
        super.setupUI()
        collectionView.registerCells(registerCells())
    }

    /// Override to customize layout (flow, compositional, etc.).
    func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }

    func registerCells() -> [TIOCollectionViewCell.Type] {
        return []
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.displayItemCount(in: section)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("collectionView(_:cellForItemAt:) must be overridden in subclass")
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = viewModel.item(at: indexPath)
        let cellType = registerCells().first ?? TIOCollectionViewCell.self
        let size = cellType.cellSize(data: data)
        if size != .zero {
            return size
        }
        let width = collectionView.bounds.width
        guard width > 0 else {
            return CGSize(width: UIScreen.main.bounds.width, height: 56)
        }
        return CGSize(width: width, height: 56)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
}
