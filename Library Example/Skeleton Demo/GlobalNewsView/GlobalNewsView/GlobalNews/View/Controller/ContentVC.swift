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
    
    private lazy var tbvList: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(NewsTableViewCell.self, forCellReuseIdentifier: String(describing: NewsTableViewCell.self))
        view.register(NativeAdmobViewCell.self, forCellReuseIdentifier: String(describing: NativeAdmobViewCell.self))
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
    
    private lazy var cltvHeaderTypeAppTbvView: CltvHeaderTypeAppView = {
        let view = CltvHeaderTypeAppView(uiModel: modelSetupView)
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var cltvHeaderTypeOtherTbvView: CltvHeaderTypeOtherView = {
        let view = CltvHeaderTypeOtherView(uiModel: modelSetupView)
        view.backgroundColor = .clear
        return view
    }()
    
    private var modelSetupView: GlobalNewsUIModel!
    
    private lazy var refresherTbv = IQPullToRefresh(
        scrollView: tbvList,
        refresher: self,
        moreLoader: self)
    
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
    
    init(tabModel: GlobalNewsTabModel, modelUI: GlobalNewsUIModel) {
        self.perTabModel = tabModel
        self.modelSetupView = modelUI
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = modelSetupView.globalNewsViewBackground
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
        
        if !perTabModel.app.isEmpty {
            tbvList.tableHeaderView = cltvHeaderTypeAppTbvView
            cltvHeaderTypeAppTbvView.snp.makeConstraints { make in
                make.top.centerX.width.equalToSuperview()
                make.height.equalTo(254 + (254 * 0.25))
            }
        } else {
            tbvList.tableHeaderView = cltvHeaderTypeOtherTbvView
            cltvHeaderTypeOtherTbvView.snp.makeConstraints { make in
                make.top.centerX.width.equalToSuperview()
                make.height.equalTo(246)
            }
        }
       
        view.isSkeletonable = true
        tbvList.isSkeletonable = true
        setupLoadIndicator()
        showSkleton()
    }
    
    private func showSkleton() {
        if refresherTbv.isRefreshing {
            view.showAnimatedGradientSkeleton()
        } else {
            view.stopSkeletonAnimation()
            view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
        }
        cltvHeaderTypeAppTbvView.renderUI(refresherTbv: refresherTbv.isRefreshing, modelSource: globalRequestNewsViewModel.dataSource.pin_news)
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
                
                if let haveIsNative = globalRequestNewsViewModel.isRemoveNative, haveIsNative {
                    globalRequestNewsViewModel.clearIndexUpdate()
                    return
                }
                
                if let haveIndexUpdate = globalRequestNewsViewModel.updateAtIndex {
                    tbvList.reloadRows(at: [haveIndexUpdate], with: .none)
                    globalRequestNewsViewModel.clearIndexUpdate()
                    return
                }
                
                if !dataSource.pin_news.isEmpty {
                    if tbvList.tableHeaderView == nil {
                        if !perTabModel.app.isEmpty {
                            tbvList.tableHeaderView = cltvHeaderTypeAppTbvView
                            cltvHeaderTypeAppTbvView.snp.remakeConstraints { make in
                                make.top.centerX.width.equalToSuperview()
                                make.height.equalTo(254 + (254 * 0.25))
                            }
                        } else {
                            tbvList.tableHeaderView = cltvHeaderTypeOtherTbvView
                            cltvHeaderTypeOtherTbvView.snp.remakeConstraints { make in
                                make.top.centerX.width.equalToSuperview()
                                make.height.equalTo(246)
                            }
                        }
                    }
                    renderUICltvType()
                } else {
                    tbvList.tableHeaderView = nil
                }
                
                if !dataSource.list_news.isEmpty {
                    tbvList.reloadData()
                }
            }.store(in: &cancellables)
    }
    
    
    
    private func renderUICltvType() {
        if !perTabModel.app.isEmpty {
            cltvHeaderTypeAppTbvView.renderUI(refresherTbv: refresherTbv.isRefreshing, modelSource: globalRequestNewsViewModel.dataSource.pin_news)
        } else {
            cltvHeaderTypeOtherTbvView.renderUI(refresherTbv: refresherTbv.isRefreshing, modelSource: globalRequestNewsViewModel.dataSource.pin_news)
        }
    }
}


// MARK: TableView
extension ContentVC: SkeletonTableViewDelegate, SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return String(describing: NewsTableViewCell.self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  globalRequestNewsViewModel.dataSource.list_news.isEmpty ? 0: 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if perTabModel.list_news_title.isEmpty {
            return 0
        }
        return globalRequestNewsViewModel.dataSource.list_news.isEmpty ? 0: 40.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if perTabModel.list_news_title.isEmpty {
            return nil
        }
        let myLabel = UILabel()
        myLabel.textColor = .black
        myLabel.font = .boldSystemFont(ofSize: 24)
        let headerView = UIView()
        myLabel.text = perTabModel.list_news_title
        headerView.addSubview(myLabel)
        headerView.backgroundColor = .clear
        myLabel.snp.makeConstraints { make in
            make.centerY.equalTo(headerView.snp.centerY)
            make.height.equalTo(myLabel.font.pointSize)
            make.leading.equalTo(headerView.snp.leading).offset(16.0)
        }
        return headerView
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalRequestNewsViewModel.dataSource.list_news.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if globalRequestNewsViewModel.dataSource.list_news[indexPath.row].isNative {
            return 156
        } else {
            return heightTable
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if globalRequestNewsViewModel.dataSource.list_news[indexPath.row].isNative {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NativeAdmobViewCell.self), for: indexPath) as? NativeAdmobViewCell else {
                return UITableViewCell()
            }
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.delegate = self
//            cell.setupViewNativeAdmob(atIndex: indexPath)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NewsTableViewCell.self), for: indexPath) as? NewsTableViewCell else {
                return UITableViewCell()
            }
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            let model = globalRequestNewsViewModel.dataSource.list_news.isEmpty ? GlobaleListNews(): globalRequestNewsViewModel.dataSource.list_news[indexPath.row]
            cell.setViewCell(model: model)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if refresherTbv.isRefreshing {
            cell.showAnimatedGradientSkeleton()
        }
        
        if let haveCell = cell as? NativeAdmobViewCell {
            haveCell.setupViewNativeAdmob()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        globalRequestNewsViewModel.updateTotalView(indexPath: indexPath)
        view.pushNavigationToReadNews(modelNews: globalRequestNewsViewModel.dataSource.list_news[indexPath.item])
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
        renderUICltvType()
        globalRequestNewsViewModel.getBodyList(model: perTabModel)
    }
    
    func loadMoreTriggered(type: IQPullToRefresh.LoadMoreType,
                           loadingBegin: @Sendable @escaping @MainActor (_ success: Bool) -> Void,
                           loadingFinished: @Sendable @escaping @MainActor (_ success: Bool) -> Void) {
        loadingBegin(true)
        globalRequestNewsViewModel.getBodyList(model: perTabModel, refresh: false)
    }
}

// MARK: NativeAdmobViewCellDelegate
extension ContentVC: NativeAdmobViewCellDelegate {
    func removeAtIndex(cell: NativeAdmobViewCell) {
        if let indexPath = tbvList.indexPath(for: cell),
           globalRequestNewsViewModel.dataSource.list_news[indexPath.row].isNative {
            globalRequestNewsViewModel.removeNativeCell(atIndex: indexPath)
            tbvList.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
