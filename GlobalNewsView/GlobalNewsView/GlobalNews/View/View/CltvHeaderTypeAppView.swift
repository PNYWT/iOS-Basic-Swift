//
//  CltvHeaderTypeAppView.swift
//  GlobalNewsView
//
//  Created by Dev on 15/1/2568 BE.
//

import Foundation
import UIKit
import SnapKit
import SkeletonView
import CHIPageControl

class CltvHeaderTypeAppView: UIView {
    private lazy var cltvPinApp: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(PinAppCltvViewCell.self, forCellWithReuseIdentifier: PinAppCltvViewCell.cellIndetifier)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.isPagingEnabled = true
        return view
    }()
    
    private lazy var pageControl: CHIPageControlJaloro = {
        let view = CHIPageControlJaloro()
        view.numberOfPages = 0
        view.radius = 4
        view.tintColor = modelSetupView.pageControlColorNonSelect
        view.currentPageTintColor = modelSetupView.pageControlColorSelect
        view.padding = 6.0
        view.elementWidth = 30
        view.elementHeight = 1.5
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
        self.modelSetupView = uiModel
        self.perTabModel = perTabModel
        super.init(frame: .zero)
        commonInit()
    }
    
    public func renderUI(refresherTbv: Bool, modelSource: [GlobaleListNews]) {
        self.refresherTbv = refresherTbv
        self.dataSource = modelSource
        pageControl.numberOfPages = dataSource.count
        showSkleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        isSkeletonable = true
        addSubview(cltvPinApp)
        cltvPinApp.isSkeletonable = true
        cltvPinApp.snp.makeConstraints { make in
            make.top.centerX.width.equalToSuperview()
            make.height.equalToSuperview().offset(-8.0)
        }
        
        addSubview(pageControl)
        pageControl.isSkeletonable = true
        pageControl.snp.makeConstraints { make in
            make.height.equalTo(5)
            make.width.centerX.equalTo(cltvPinApp)
            make.bottom.equalTo(cltvPinApp.snp.bottom)
        }
        bringSubviewToFront(pageControl)
    }
    
    private func showSkleton() {
        if refresherTbv {
            self.showAnimatedGradientSkeleton()
        } else {
            self.stopSkeletonAnimation()
            self.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
        }
        cltvPinApp.reloadData()
        pageControl.isHidden = dataSource.isEmpty
    }
}

// MARK: CollectionView

extension CltvHeaderTypeAppView: SkeletonCollectionViewDataSource, UICollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return PinAppCltvViewCell.cellIndetifier
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return dataSource.count
        totalElements = buffer + dataSource.count
        return totalElements
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PinAppCltvViewCell.cellIndetifier, for: indexPath) as? PinAppCltvViewCell else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = .clear
        let currentCell = getIndexPathNew(indexPath: indexPath)
        cell.setViewCell(model: dataSource[currentCell.item])
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
            let currentIndex = Int(round(Double(collectionView.contentOffset.x)/Double(itemSize))) % dataSource.count
            pageControl.set(progress: currentIndex, animated: false)
        }
    }
    
    private func getIndexPathNew(indexPath: IndexPath) -> IndexPath {
        let currentCell = indexPath.row % dataSource.count
        let indexPathNew = IndexPath(item: currentCell, section: indexPath.section)
        return indexPathNew
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentCell = getIndexPathNew(indexPath: indexPath)
        pushNavigationToReadNews(
            sectionName: perTabModel.cat_name,
            modelNews: dataSource[currentCell.item])
    }
}

extension CltvHeaderTypeAppView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width,
                      height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init() // .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if refresherTbv {
            cell.showAnimatedGradientSkeleton()
        }
    }
}

