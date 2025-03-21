//
//  GlobalNewsViewController.swift
//  GlobalNewsView
//
//  Created by Dev on 8/1/2568 BE.
//

import UIKit
import SnapKit
import Combine

class GlobalNewsViewController: UIViewController {
    
    // ViewModel
    private var globalNewsViewModel = GlobalNewsViewModel()
    
    // UI Source
    private var uiViewModel: GlobalNewsUIModel! = GlobalNewsUIModel.init()
    
    // Combine event
    private var cancellables = Set<AnyCancellable>()
    private var getDataTabEvent: AnyCancellable?
    
    // UI
    private lazy var globalNewsView: GlobalNewsHeaderView = {
        let view = GlobalNewsHeaderView(uiModel: uiViewModel)
        return view
    }()
    
    private lazy var pageViewController: DetailPageViewController = {
        let view = DetailPageViewController(pageCollection: globalNewsViewModel.pageCollection, transitionStyle: .scroll, navigationOrientation: .horizontal)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBinding()
    }
    
    private func setupView() {
        view.addSubview(globalNewsView)
        globalNewsView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(50.0)
        }
    }
    
    private func setupBinding() {
        cancellables.removeAll()
        getDataTabEvent = globalNewsViewModel.$tabModel
            .receive(on: DispatchQueue.main)
            .filter({
                $0 != nil && !$0!.isEmpty
            })
            .sink { [weak self] tabModel in
                guard let self = self, let haveTab = tabModel else {
                    return
                }
                globalNewsView.renderUI(tabModelDatasource: haveTab)
                pageViewController.refreshUI(pageCollection: globalNewsViewModel.pageCollection)
                setupContentView()
                getDataTabEvent = nil
            }
        
        globalNewsViewModel.messageAlert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ตกลง", style: .default))
                self?.present(alert, animated: true)
            }.store(in: &cancellables)
        
        globalNewsView.sendEventTag
            .receive(on: DispatchQueue.main)
            .sink { [weak self] indexPage in
                guard let self = self else {
                    return
                }
                
                pageViewController.slidePage(indexPage: indexPage)
            }.store(in: &cancellables)
        
        pageViewController.sendEventSelectButton
            .receive(on: DispatchQueue.main)
            .sink { [weak self] indexPage in
                guard let self = self else {
                    return
                }
                globalNewsView.selectAtButtonByIndexPage(index: indexPage)
            }.store(in: &cancellables)
        
        globalNewsViewModel.getTabHeader(contentBackground: uiViewModel.globalNewsViewBackground)
    }
    
    @MainActor
    private func setupContentView() {
        var scrollToItem = 0
        if let haveDefaultPage = globalNewsViewModel.tabModel.firstIndex(where: {
            $0.cat_default
        }) {
            scrollToItem = haveDefaultPage
        }
        
        pageViewController.slidePage(indexPage: scrollToItem)
        
        addChild(pageViewController)
        pageViewController.willMove(toParent: self)
        view.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { make in
            make.centerX.width.equalToSuperview()
            make.top.equalTo(self.globalNewsView.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
}


