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
    
    // UI Scoure
    private var modelSetupView: GlobalNewsUIModel!
    
    // Data Source
    private var dataSource: [GlobaleListNews] = []
    private var refresherTbv: Bool! = false
    
    init(uiModel: GlobalNewsUIModel) {
        self.modelSetupView = uiModel
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
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PinAppCltvViewCell.cellIndetifier, for: indexPath) as? PinAppCltvViewCell else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = .clear
        cell.setViewCell(model: dataSource[indexPath.item])
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cltv = scrollView as? UICollectionView {
            let total = cltv.contentSize.width - cltv.bounds.width
            let offset = cltv.contentOffset.x
            let percent = Double(offset / total)
            
            let progress = percent * Double(dataSource.count - 1)
            pageControl.progress = progress
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pushNavigationToReadNews(modelNews: dataSource[indexPath.item])
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

