
import UIKit
import SnapKit
import SDWebImage
import SkeletonView

class BannerEventViewCell: BaseCollectionViewCell {
    
    private(set) lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private(set) lazy var imageMain: UIImageView = {
        let view = createImageView(background: .clear, contentMode: .scaleAspectFill)
/*
 let blurEffect = UIBlurEffect(style: .dark)
 let blurredEffectView = UIVisualEffectView(effect: blurEffect)
 blurredEffectView.alpha = 0.3
 view.addSubview(blurredEffectView)
 blurredEffectView.snp.makeConstraints { make in
     make.edges.equalToSuperview()
 }
 */
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.backgroundColor = .clear
        self.addCornerRadius(with: .custom, radius: 16)
        setupView()
    }

    private func setupView() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageMain)
        containerView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        imageMain.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.setupSkeletonCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setViewCell(bannerModel: BannerType?) {
        let isLoading = bannerModel == nil ? true : false
        self.showSkleton(with: isLoading)
        self.containerView.subviews.forEach { view in
            view.isHidden = isLoading
        }
        switch bannerModel {
        case .event(let eventListModel):
            imageMain.setImageURL(imagePath: eventListModel.eventBanner, defalutImage: UIImage())
        case .topup(let bannerTopupModel):
            imageMain.setImageURL(imagePath: bannerTopupModel.banner, defalutImage: UIImage())
        case nil:
            break
        }

    }
}
