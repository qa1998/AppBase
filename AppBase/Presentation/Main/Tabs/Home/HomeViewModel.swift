//
//  HomeViewModel.swift
//  AppBase
//
//  Created by Quang Anh Le on 11/5/26.
//

import BaseMVVM
import Foundation
import Combine

class HomeViewModel: TIOListViewModel {
    var items: [Int] = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
    var page: Int = 1
    
    override func numOfItemsInSection(_ section: Int) -> Int {
        return items.count
    }
    
    override func refreshAndGetListData() {
        self.page = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.items = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
            self.dataDidChange.send()
        }
    }
    
    override func loadMoreData() {
        let itemsLoaMore: [Int] = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.page += 1
            let startIndex = self.items.count
            let countInsert = itemsLoaMore.count
            self.items.append(contentsOf: itemsLoaMore)
            self.dataDidInsert.send((startIndex, countInsert))
        }
    }
    
    override func canLoadMore() -> Bool {
        return page == 3
    }
}
