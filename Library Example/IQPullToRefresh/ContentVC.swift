//
//  ContentVC.swift
//  GlobalNewsView
//
//  Created by Dev on 8/1/2568 BE.
//

import UIKit
import SnapKit
import IQPullToRefresh

class ContentVC: UIViewController {
    
    // viewModel
    private var globalRequestNewsViewModel = GlobalRequestNewsViewModel()
    
    private var perTabModel: GlobalNewsTabModel!
    
    private lazy var tbvList: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(NewsTableViewCell.self, forCellReuseIdentifier: String(describing: NewsTableViewCell.self))
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.separatorStyle = .none
        return view
    }()
    
    private lazy var refresher = IQPullToRefresh(
        scrollView: tbvList,
        refresher: self,
        moreLoader: self)
    
    private func setupLoadIndicator() {
        refresher.enablePullToRefresh = true
        refresher.enableLoadMore = true
        refresher.refreshControl.tintColor = .gray
        refresher.loadMoreControl = PreloadActivityIndicatorView(style: .medium)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.refresher.refresh()
        }
    }
    
    private lazy var buttonTest: UIButton = {
        let view = UIButton()
        view.setTitleColor(.yellow, for: .normal)
        view.addTarget(self, action: #selector(sendRequest), for: .touchUpInside)
        return view
    }()
    
    init(tabModel: GlobalNewsTabModel) {
        self.perTabModel = tabModel
        super.init(nibName: nil, bundle: nil)
        
        buttonTest.setTitle(String(format: "%@", tabModel.cat_name), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(buttonTest)
        buttonTest.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        
        view.addSubview(tbvList)
        tbvList.snp.makeConstraints { make in
            make.top.centerX.bottom.width.equalToSuperview()
        }
        
        setupLoadIndicator()
    }
    
    @objc private func sendRequest() {
        globalRequestNewsViewModel.getBodyList(model: perTabModel)
    }
}

extension ContentVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NewsTableViewCell.self), for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
//        cell.setView(model: dataNews[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: Refresh, Pull-up
extension ContentVC: Refreshable, MoreLoadable {
    func refreshTriggered(type: IQPullToRefresh.RefreshType,
                          loadingBegin: @Sendable @escaping @MainActor (_ success: Bool) -> Void,
                          loadingFinished: @Sendable @escaping @MainActor (_ success: Bool) -> Void) {
        loadingBegin(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            loadingFinished(true)
        }
    }
    
    func loadMoreTriggered(type: IQPullToRefresh.LoadMoreType,
                           loadingBegin: @Sendable @escaping @MainActor (_ success: Bool) -> Void,
                           loadingFinished: @Sendable @escaping @MainActor (_ success: Bool) -> Void) {
        loadingBegin(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            loadingFinished(true)
        }
    }
}
