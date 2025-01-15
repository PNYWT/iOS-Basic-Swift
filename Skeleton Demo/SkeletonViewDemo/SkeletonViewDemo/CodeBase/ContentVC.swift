//
//  ContentVC.swift
//  GlobalNewsView
//
//  Created by Dev on 8/1/2568 BE.
//

import UIKit
import SnapKit
import IQPullToRefresh
import Combine
import SkeletonView

class ContentVC: UIViewController {
    
    // Combine
    private var cancellables = Set<AnyCancellable>()
    
    // viewModel
    private var globalRequestNewsViewModel = GlobalRequestNewsViewModel()
    
    private var perTabModel: GlobalNewsTabModel!
    
    private var heightTable: CGFloat = 126
    
    private lazy var cltvPin: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(PinCltvViewCell.self, forCellWithReuseIdentifier: PinCltvViewCell.cellIndetifier)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var tbvList: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(NewsTableViewCell.self, forCellReuseIdentifier: String(describing: NewsTableViewCell.self))
        view.showsVerticalScrollIndicator = true
        view.showsHorizontalScrollIndicator = false
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.estimatedRowHeight = heightTable
        view.tableHeaderView = nil
        view.sectionHeaderHeight = 0.0
        return view
    }()
    
    private lazy var refresherTbv = IQPullToRefresh(
        scrollView: tbvList,
        refresher: self,
        moreLoader: self)
    
    /*
     private lazy var refresherCltv = IQPullToRefresh(
         scrollView: cltvPin,
         refresher: self,
         moreLoader: self)
     */
    
    private func setupLoadIndicator() {
        refresherTbv.enablePullToRefresh = true
        refresherTbv.enableLoadMore = true
        refresherTbv.refreshControl.tintColor = .gray
        refresherTbv.loadMoreControl = PreloadActivityIndicatorView(style: .medium)
        refresherTbv.refresh()
    }
    
    override func viewDidLayoutSubviews() {
        view.layoutSkeletonIfNeeded()
    }
    
    init(tabModel: GlobalNewsTabModel, background: UIColor) {
        self.perTabModel = tabModel
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = background
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        setupView()
    }
    
    private func setupView() {
        view.addSubview(tbvList)
        tbvList.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tbvList.tableHeaderView = cltvPin
        cltvPin.snp.makeConstraints { make in
            make.top.centerX.width.equalToSuperview()
            make.height.equalTo(246)
        }
        view.isSkeletonable = true
        tbvList.isSkeletonable = true
        cltvPin.isSkeletonable = true
        setupLoadIndicator()
        showSkleton()
    }
    
    private func showSkleton() {
        if refresherTbv.isRefreshing {
            cltvPin.showAnimatedGradientSkeleton()
            view.showAnimatedGradientSkeleton()
        } else {
            view.stopSkeletonAnimation()
            view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
            cltvPin.stopSkeletonAnimation()
            cltvPin.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
        }
    }
    
    private func setupBinding() {
        globalRequestNewsViewModel.$dataSource
            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
            .dropFirst()
            .filter { dataSource in
                !dataSource.list_news.isEmpty ||
                !dataSource.pin_news.isEmpty
            }
            .sink { [weak self] dataSource in
                guard let self = self else {
                    return
                }
                refresherTbv.stopRefresh()
                refresherTbv.stopLoadMore()
                showSkleton()
                if !dataSource.pin_news.isEmpty {
                    if tbvList.tableHeaderView == nil {
                        tbvList.tableHeaderView = cltvPin
                        cltvPin.snp.makeConstraints { make in
                            make.top.centerX.width.equalToSuperview()
                            make.height.equalTo(246)
                        }
                    }
                    cltvPin.reloadData()
                } else {
                    tbvList.tableHeaderView = nil
                }
                
                if !dataSource.list_news.isEmpty {
                    tbvList.reloadData()
                }
            }.store(in: &cancellables)
    }
}


// MARK: TableView
extension ContentVC: SkeletonTableViewDelegate, SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return String(describing: NewsTableViewCell.self)
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalRequestNewsViewModel.dataSource.list_news.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightTable
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NewsTableViewCell.self), for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        let model = globalRequestNewsViewModel.dataSource.list_news.isEmpty ? GlobaleListNews(): globalRequestNewsViewModel.dataSource.list_news[indexPath.row]
        cell.setViewCell(model: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if refresherTbv.isRefreshing {
            cell.showAnimatedGradientSkeleton()
        }
    }
}

// MARK: ScrollView Refresh, Pull-up
extension ContentVC: Refreshable, MoreLoadable {
    func refreshTriggered(type: IQPullToRefresh.RefreshType,
                          loadingBegin: @Sendable @escaping @MainActor (_ success: Bool) -> Void,
                          loadingFinished: @Sendable @escaping @MainActor (_ success: Bool) -> Void) {
        loadingBegin(true)
        tbvList.visibleCells.forEach { cell in
            cell.showAnimatedGradientSkeleton()
        }
        cltvPin.visibleCells.forEach { cell in
            cell.showAnimatedGradientSkeleton()
        }
        globalRequestNewsViewModel.getBodyList(model: perTabModel)
    }
    
    func loadMoreTriggered(type: IQPullToRefresh.LoadMoreType,
                           loadingBegin: @Sendable @escaping @MainActor (_ success: Bool) -> Void,
                           loadingFinished: @Sendable @escaping @MainActor (_ success: Bool) -> Void) {
        loadingBegin(true)
        globalRequestNewsViewModel.getBodyList(model: perTabModel, refresh: false)
    }
}

// MARK: CollectionView

extension ContentVC: SkeletonCollectionViewDataSource, UICollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return PinCltvViewCell.cellIndetifier
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return globalRequestNewsViewModel.dataSource.pin_news.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PinCltvViewCell.cellIndetifier, for: indexPath) as? PinCltvViewCell else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = .clear
        cell.setViewCell(model: globalRequestNewsViewModel.dataSource.pin_news[indexPath.item])
        return cell
    }
}

extension ContentVC: UICollectionViewDelegateFlowLayout {
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
        if refresherTbv.isRefreshing {
            cell.showAnimatedGradientSkeleton()
        }
    }
}
