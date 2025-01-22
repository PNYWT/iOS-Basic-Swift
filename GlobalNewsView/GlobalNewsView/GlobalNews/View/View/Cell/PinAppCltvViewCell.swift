//
//  PinCltvViewCell.swift
//  GlobalNewsView
//
//  Created by Dev on 8/1/2568 BE.
//

import UIKit
import SnapKit
import SDWebImage
import SkeletonView

class PinAppCltvViewCell: UICollectionViewCell {
    
    static let cellIndetifier = "PinAppCltvViewCell"
    
    private lazy var viewContentMain: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.makeCornerRadius(radius: 16.0, needMasksToBounds: true)
        return view
    }()

    private lazy var imageMain: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.alpha = 0.3
        view.addSubview(blurredEffectView)
        blurredEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()
    
    private lazy var viewContent: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var lbTitleNews: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.numberOfLines = 0
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 15, weight: .regular)
        return view
    }()
    
    /*
     private lazy var btnReadMore: CustomButton = {
         let view = CustomButton.init(colorSelect: .clear, colorNormal: .white, titleColor: .black, isHighlighted: false, isSelected: false)
         view.setTitle("อ่านต่อ", for: .normal)
         view.titleLabel?.font = .systemFont(ofSize: 14)
         view.addTarget(self, action: #selector(actionReadMore), for: .touchUpInside)
         view.makeCornerRadius(radius: 16.0, needMasksToBounds: true)
         return view
     }()
     */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
   /*
    btnReadMore.isSkeletonable = true
    lbTitleNews.isSkeletonable = true
    */
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setupView()
    }

    
    private func setupView() {
        contentView.addSubview(viewContentMain)
        viewContentMain.addSubview(imageMain)
        viewContentMain.addSubview(viewContent)
        viewContent.addSubview(lbTitleNews)
        /*
         contentView.addSubview(btnReadMore)
         contentView.addSubview(lbTitleNews)
         */
        
        viewContentMain.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalToSuperview().offset(-32)
        }
        
        imageMain.snp.makeConstraints { make in
            make.centerX.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(1.0 - 0.25)
            make.top.equalToSuperview()
        }
        
        viewContent.snp.makeConstraints { make in
            make.centerX.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.25)
            make.bottom.equalToSuperview()
        }
        
        lbTitleNews.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-16.0)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(4.0)
            make.bottom.lessThanOrEqualToSuperview().offset(-4)
        }
        
        contentView.isSkeletonable = true
        viewContentMain.isSkeletonable = true
        imageMain.isSkeletonable = true
        viewContent.isSkeletonable = true
        lbTitleNews.isSkeletonable = true
        
        /*
         btnReadMore.snp.makeConstraints { make in
             make.bottom.equalTo(imageMain.snp.bottom).offset(-8.0)
             make.height.equalTo(34)
             make.width.equalTo(34 * (3/1))
             make.centerX.equalToSuperview()
         }
         
         lbTitleNews.snp.makeConstraints { make in
             make.centerX.equalTo(btnReadMore)
             make.bottom.equalTo(btnReadMore.snp.top).offset(-8.0)
             make.width.equalTo(imageMain).offset(-16.0)
         }
         */
        contentView.showAnimatedGradientSkeleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setViewCell(model: GlobaleListNews) {
        imageMain.sd_setImage(with: URL(string: model.image)) { [weak self] _, _, _, _ in
            guard let self = self else {
                return
            }
            stopSkeletonAnimation()
            hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
            lbTitleNews.text = model.title
        }
    }
}
