
import UIKit
import SnapKit
import SkeletonView
import Combine

class BannerEventView: UIView {
    
    private lazy var cltvPinApp: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = FactoryCollection.createCollection(layout: layout, cells: [BannerEventViewCell.self])
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.isPagingEnabled = true
        let (dataSource, delegate) = setupDataSourceDataDelegate(cltv: view)
        view.dataSource = dataSource
        view.delegate = delegate
        return view
    }()
    
    private func setupDataSourceDataDelegate(cltv: UICollectionView) -> (BannerDataSource, BannerDelegate) {
        let dataSource = BannerDataSource()
        let delegate = BannerDelegate(collectionView: cltv, pageControl: pageControl) { [weak self] indexPath in
            guard let self else { return }
            if let modelEvent = dataSource.dataSource[indexPath.item].eventDisplay {
                onSelectedBanner(modelEvent)
            }
        }
        dataSource.updateDelegate(delegate: delegate)
        return (dataSource, delegate)
    }
    
    private lazy var pageControl: CustomPageControl = {
        let view = CustomPageControl()
        view.numberOfPages = 0
        view.currentPage = 0
        view.dotSize = 8.0
        view.dotSpacing = 6.0
        view.activeColor = .black
        view.inactiveColor = .lightGray
        return view
    }()
    
    private var bannerViewModel: BannerViewModel
    private var onSelectedBanner: ((_ modelBanner: EventListModel) -> Void)
    init(bannerViewModel: BannerViewModel, selectBanner: @escaping (_ modelBanner: EventListModel) -> Void) {
        self.bannerViewModel = bannerViewModel
        self.onSelectedBanner = selectBanner
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        addSubview(cltvPinApp)
        addSubview(pageControl)
        self.setupSkeletonCell()
        renderUI()
        self.setupBindingBanner()
    }
    
    private var cancellables: Set<AnyCancellable> = []
    private func setupBindingBanner() {
        cancellables.removeAll()
        bannerViewModel.$bannerModel
            .receive(on: DispatchQueue.main)
            .sink { (model) in
                self.renderUI(withData: model.banners)
            }.store(in: &cancellables)
        
        bannerViewModel.bannerMissionToggleService.send(true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cltvPinApp.snp.makeConstraints { make in
            make.top.centerX.width.equalToSuperview()
            make.height.equalToSuperview().offset(-8.0)
        }
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-SizeModelSpace.space8 - 4)
            make.leading.equalToSuperview().offset(SizeModelSpace.space8)
            make.height.equalTo(10.0)
        }
    }
    
    private func renderUI(withData: [BannerType] = []) {
        showSkleton(with: withData.isEmpty ? true : false)
        (cltvPinApp.dataSource as? BannerDataSource)?.updateDataSource(dataSource: withData)
        cltvPinApp.reloadData()
    }
}
