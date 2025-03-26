//
//  BannerDataSource.swift
//  Jaei
//
//  Created by Dev2 on 21/3/2568 BE.
//

import Foundation
import UIKit

class BannerDataSource: NSObject {
    
    private(set) var dataSource: [BannerType] = []
    
    private var delegate: BannerDelegate!
    override init() {
        super.init()
    }
    
    func updateDelegate(delegate: BannerDelegate) {
        self.delegate = delegate
    }
    
    func updateDataSource(dataSource: [BannerType]) {
        self.dataSource = dataSource
        self.delegate.triggerAutoScroll(dataSource: self.dataSource)
    }
}

// MARK: UICollectionViewDataSource
extension BannerDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate.totalElements
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = FactoryCollection.createCell(for: collectionView, type: .default, identifier: BannerEventViewCell.self, indexPath: indexPath)
        let realIndexPath = delegate.getIndexPathNew(indexPath: indexPath)
        (cell as? BannerEventViewCell)?.setViewCell(bannerModel: dataSource[realIndexPath.item])
        return cell
    }
}
