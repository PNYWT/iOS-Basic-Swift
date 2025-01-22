//
//  CltvHeaderTypeOtherView.swift
//  GlobalNewsView
//
//  Created by Dev on 15/1/2568 BE.
//

import UIKit
import SkeletonView
import SnapKit

class CltvHeaderTypeOtherView: UIView {
    
    private lazy var cltvPinOther: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(PinCltvOtherViewCell.self, forCellWithReuseIdentifier: PinCltvOtherViewCell.cellIndetifier)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        return view
    }()
    
    // UI Source
    private var modelSetupView: GlobalNewsUIModel!
    private var perTabModel: GlobalNewsTabModel!
    
    // Source for scroll
    private let buffer = 3
    private var totalElements: Int = 0
    
    // Data Source
    private var dataSource: [GlobaleListNews] = []
    private var refresherTbv: Bool! = false
    
    init(uiModel: GlobalNewsUIModel, perTabModel: GlobalNewsTabModel) {
        self.perTabModel = perTabModel
        self.modelSetupView = uiModel
        super.init(frame: .zero)
        commonInit()
    }
    
    public func renderUI(refresherTbv: Bool, modelSource: [GlobaleListNews]) {
        self.refresherTbv = refresherTbv
        self.dataSource = modelSource
        showSkleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        isSkeletonable = true
        addSubview(cltvPinOther)
        cltvPinOther.isSkeletonable = true
        cltvPinOther.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func showSkleton() {
        if refresherTbv {
            self.showAnimatedGradientSkeleton()
        } else {
            self.stopSkeletonAnimation()
            self.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
        }
        cltvPinOther.reloadData()
    }
}

// MARK: CollectionView

extension CltvHeaderTypeOtherView: SkeletonCollectionViewDataSource, UICollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return PinCltvOtherViewCell.cellIndetifier
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalElements = buffer + dataSource.count
        return totalElements
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PinCltvOtherViewCell.cellIndetifier, for: indexPath) as? PinCltvOtherViewCell else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = .clear
        cell.delegate = self
        let currentCell = getIndexPathNew(indexPath: indexPath)
        cell.setViewCell(model: dataSource[currentCell.item], indexPath: currentCell)
        return cell
    }
    
    @MainActor
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            
            let itemSize = collectionView.contentSize.width/CGFloat(totalElements)
            
            if scrollView.contentOffset.x > itemSize * CGFloat(dataSource.count) {
                collectionView.contentOffset.x -= itemSize*CGFloat(dataSource.count)
            }
            if scrollView.contentOffset.x < 0  {
                collectionView.contentOffset.x += itemSize * CGFloat(dataSource.count)
            }
        }
    }
    
    private func getIndexPathNew(indexPath: IndexPath) -> IndexPath {
        let currentCell = indexPath.row % dataSource.count
        let indexPathNew = IndexPath(item: currentCell, section: indexPath.section)
        return indexPathNew
    }
}

extension CltvHeaderTypeOtherView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height - 16, height: collectionView.frame.size.height - 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return  .init(top: 0, left: 16, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if refresherTbv {
            cell.showAnimatedGradientSkeleton()
        }
    }
}

extension CltvHeaderTypeOtherView: PinCltvOtherViewCellDelegate {
    func didSelectNews(index: Int) {
        self.pushNavigationToReadNews(
            sectionName: perTabModel.cat_name,
            modelNews: dataSource[index])
    }
}

