
import UIKit

class BannerDelegate: NSObject {

    private var buffer = 2 // จำนวน clone ด้านหน้า + หลัง

    private weak var pageControl: CustomPageControl?
    private weak var collectionView: UICollectionView?
    private var rawIndex: Int = 0
    private var totalRaw: Int = 0
    private(set) var totalElements: Int = 0
    
    private var timerManager: TimerManager?

    private var didSelect: ((IndexPath) -> Void)

    // MARK: - Init
    init(
        collectionView: UICollectionView,
        pageControl: CustomPageControl,
        scrollInterval: TimeInterval = 4,
        buffer: Int = 2,
        didSelect: @escaping ((IndexPath) -> Void)
    ) {
        self.collectionView = collectionView
        self.pageControl = pageControl
        self.buffer = buffer
        self.didSelect = didSelect
        super.init()
        self.timerManager = TimerManager(scrollInterval: scrollInterval, onEventTeskTimer: { [weak self] in
            self?.scrollToNextItem()
        })
    }

    func triggerAutoScroll(dataSource: [Any]) {
        timerManager?.stopAutoScroll()
        guard !dataSource.isEmpty else {
            return
        }

        totalRaw = dataSource.count
        pageControl?.numberOfPages = totalRaw
        totalElements = totalRaw + buffer
        rawIndex = 0 // buffer / 2
        timerManager?.startAutoScroll()
    }
    
    func getIndexPathNew(indexPath: IndexPath) -> IndexPath {
        let currentCell = indexPath.row % totalRaw
        let indexPathNew = IndexPath(item: currentCell, section: indexPath.section)
        return indexPathNew
    }

    private func scrollToNextItem() {
        guard let collectionView = self.collectionView else {
            return
        }
        let itemSize = collectionView.contentSize.width / CGFloat(self.totalElements)
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut]) {
            collectionView.contentOffset.x += itemSize * 0.99
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
                collectionView.contentOffset.x += itemSize * 0.01
            } completion: { [weak self] _ in
                guard let self else { return }
                setCurrenPage(scrollView: collectionView)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension BannerDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelect(getIndexPathNew(indexPath: indexPath))
    }
}

// MARK: - UIScrollViewDelegate
extension BannerDelegate: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let isRunning = timerManager?.isTimerRunning(), isRunning {
            return
        }
        setCurrenPage(scrollView: scrollView)
    }
    
    private func setCurrenPage(scrollView: UIScrollView) {
        let itemSize = scrollView.contentSize.width / CGFloat(totalElements)
        if scrollView.contentOffset.x > itemSize * CGFloat(totalRaw) {
            scrollView.contentOffset.x -= itemSize * CGFloat(totalRaw)
        }
        
        if scrollView.contentOffset.x < 0 {
            scrollView.contentOffset.x += itemSize * CGFloat(totalRaw)
        }
        let current = Int(round(scrollView.contentOffset.x / itemSize))
        rawIndex = (current + totalRaw) % totalRaw
        pageControl?.currentPage = rawIndex
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timerManager?.stopAutoScroll()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        timerManager?.startAutoScroll()
    }
}

extension BannerDelegate: UICollectionViewDelegateFlowLayout {
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
}
