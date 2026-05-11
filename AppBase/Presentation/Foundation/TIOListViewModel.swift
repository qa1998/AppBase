//
//  TIOListViewModel.swift
//  AppBase
//
//  Created by QuangAnh on 8/5/26.
//

import UIKit
import BaseMVVM

class TIOListViewModel: TIOViewModel {
    func numberOfSections() -> Int {
        return 1
    }
    
    func numOfItemsInSection(_ section: Int) -> Int {
        return 0
    }
    
    func item(at indexPath: IndexPath) -> Any? {
        return nil
    }
    
    func didSelectItem(at: IndexPath) {
        
    }
    
    func refreshAndGetListData() {
        
    }
    
    func loadMoreData() {
        
    }
    
    func canLoadMore() -> Bool {
        return false
    }
    
    func isEmpty() -> Bool {
        var total: Int = 0
        for section in 0..<numberOfSections() {
            total += numOfItemsInSection(section)
        }
        return total == 0
    }
}

