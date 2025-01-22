//
//  PinCltvOtherViewCell.swift
//  GlobalNewsView
//
//  Created by Dev on 15/1/2568 BE.
//

import UIKit
import SnapKit
import SDWebImage
import SkeletonView

protocol PinCltvOtherViewCellDelegate: AnyObject {
    func didSelectNews(index: Int)
}

class PinCltvOtherViewCell: UICollectionViewCell {
    
    static let cellIndetifier = "PinCltvOtherViewCell"
    
    weak var delegate: PinCltvOtherViewCellDelegate?

    private lazy var imageMain: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.makeCornerRadius(radius: 16.0, needMasksToBounds: true)
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.alpha = 0.3
        view.addSubview(blurredEffectView)
        blurredEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()
    
    private lazy var lbTitleNews: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.numberOfLines = 2
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 14, weight: .bold)
        return view
    }()
    
    private lazy var btnReadMore: CustomButton = {
        let view = CustomButton.init(colorSelect: .clear, colorNormal: .white, titleColorNormal: .black, isHighlighted: false, isSelected: false)
        view.setTitle("อ่านต่อ", for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 14)
        view.addTarget(self, action: #selector(actionReadMore), for: .touchUpInside)
        view.makeCornerRadius(radius: 16.0, needMasksToBounds: true)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isSkeletonable = true
        imageMain.isSkeletonable = true
        btnReadMore.isSkeletonable = true
        lbTitleNews.isSkeletonable = true
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setupView()
        self.showAnimatedGradientSkeleton()
    }
    
    private func setupView() {
        contentView.addSubview(imageMain)
        contentView.addSubview(btnReadMore)
        contentView.addSubview(lbTitleNews)
        
        imageMain.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        btnReadMore.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8.0)
            make.height.equalTo(34)
            make.width.equalTo(34 * (3/1))
            make.centerX.equalToSuperview()
        }
        
        lbTitleNews.snp.makeConstraints { make in
            make.centerX.equalTo(btnReadMore)
            make.bottom.equalTo(btnReadMore.snp.top).offset(-8.0)
            make.width.equalToSuperview().offset(-16.0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setViewCell(model: GlobaleListNews, indexPath: IndexPath!) {
        btnReadMore.tag = indexPath.item
        imageMain.sd_setImage(with: URL(string: model.image)) { [weak self] _, _, _, _ in
            guard let self = self else {
                return
            }
            stopSkeletonAnimation()
            hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
            lbTitleNews.text = model.title
        }
    }
    
    @objc private func actionReadMore(sender: UIButton) {
        delegate?.didSelectNews(index: sender.tag)
    }
}

