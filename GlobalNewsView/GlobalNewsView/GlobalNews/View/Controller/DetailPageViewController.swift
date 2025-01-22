//
//  DetailPageViewController.swift
//  GlobalNewsView
//
//  Created by Dev on 8/1/2568 BE.
//

import UIKit
import Combine

class DetailPageViewController: UIPageViewController {
    
    private var pageCollectionModel: PageCollection!
    private var currentIndex: Int! = 0
    
    var sendEventSelectButton = PassthroughSubject<Int, Never>()
    
    init(pageCollection: PageCollection,
        transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        self.pageCollectionModel = pageCollection
        self.dataSource = self
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func refreshUI(pageCollection: PageCollection) {
        self.pageCollectionModel = pageCollection
    }
    
    @MainActor
    public func slidePage(indexPage: Int) {
        let direction: UIPageViewController.NavigationDirection = indexPage > currentIndex ? .forward : .reverse
        setViewControllers([pageCollectionModel.pages[indexPage].vc], direction: direction, animated: true)
        currentIndex = indexPage
    }
}

extension DetailPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewController = self.viewControllers?.first else {
            return
        }
        if let currentViewControllerIndex = pageCollectionModel.pages.firstIndex(where: { $0.vc == viewController }) {
            currentIndex = currentViewControllerIndex
            sendEventSelectButton.send(currentViewControllerIndex)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentViewControllerIndex = pageCollectionModel.pages.firstIndex(where: { $0.vc == viewController }) {
            if (1..<pageCollectionModel.pages.count).contains(currentViewControllerIndex) {
                // go to previous page in array
                return pageCollectionModel.pages[currentViewControllerIndex - 1].vc
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentViewControllerIndex = pageCollectionModel.pages.firstIndex(where: { $0.vc == viewController }) {
            
            if (0..<(pageCollectionModel.pages.count - 1)).contains(currentViewControllerIndex) {
                // go to next page in array
                return pageCollectionModel.pages[currentViewControllerIndex + 1].vc
            }
        }
        return nil
    }
}
