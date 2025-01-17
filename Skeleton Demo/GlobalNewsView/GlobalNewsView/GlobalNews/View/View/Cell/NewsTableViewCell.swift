//
//  NewsTableViewCell.swift
//  GlobalNewsView
//
//  Created by Dev on 10/1/2568 BE.
//

import UIKit
import SnapKit
import SDWebImage
import SkeletonView

class NewsTableViewCell: UITableViewCell {
    
    private lazy var contentCellView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.makeCornerRadius(radius: 16.0, needMasksToBounds: true)
        return view
    }()
    
    private lazy var imageNews: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.backgroundColor = .clear
        view.makeCornerRadius(radius: 16.0, needMasksToBounds: true)
        return view
    }()
    
    private lazy var pinNews: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.backgroundColor = .clear
        view.image = .icPin
        view.isHidden = true
        return view
    }()
    
    private lazy var lbTitleNews: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textColor = .black
        view.numberOfLines = 2
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 18)
        return view
    }()
    
    private lazy var lbView: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textColor = #colorLiteral(red: 0.717647016, green: 0.717647016, blue: 0.717647016, alpha: 1)
        view.textAlignment = .right
        view.font = .systemFont(ofSize: 12)
        return view
    }()
    
    private lazy var lbDate: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textColor = #colorLiteral(red: 0.717647016, green: 0.717647016, blue: 0.717647016, alpha: 1)
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 12)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            contentCellView.alpha = 0.5
        } else {
            contentCellView.alpha = 1.0
        }
    }

    private func commonInit() {
        contentView.addSubview(contentCellView)
        contentView.addSubview(pinNews)
        contentCellView.addSubview(imageNews)
        contentCellView.addSubview(lbTitleNews)
        contentCellView.addSubview(lbDate)
        contentCellView.addSubview(lbView)
        isSkeletonable = true
        contentCellView.isSkeletonable = true
        imageNews.isSkeletonable = true
        lbTitleNews.isSkeletonable = true
        lbView.isSkeletonable = true
        lbDate.isSkeletonable = true
        
        contentCellView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6.0)
            make.bottom.equalToSuperview().offset(-6.0)
            make.width.equalToSuperview().offset(-32.0)
            make.centerX.equalToSuperview()
        }
        
        pinNews.snp.makeConstraints { make in
            make.centerX.equalTo(contentCellView.snp.leading).offset(8)
            make.centerY.equalTo(contentCellView.snp.top).offset(8)
            make.width.height.equalTo(30.0)
        }
        
        lbTitleNews.snp.makeConstraints { make in
            make.leading.equalTo(imageNews.snp.trailing).offset(8.0)
            make.top.equalTo(imageNews.snp.top)
            make.trailing.equalToSuperview().offset(-8.0)
        }
        
        lbDate.snp.makeConstraints { make in
            make.leading.equalTo(lbTitleNews.snp.leading)
            make.bottom.equalTo(imageNews.snp.bottom)
            make.width.greaterThanOrEqualTo(20)
        }
        
        lbView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8.0)
            make.centerY.equalTo(lbDate)
            make.width.greaterThanOrEqualTo(20)
        }
        
        imageNews.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8.0)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().offset(-16.0)
            let desiredHeight: CGFloat = contentView.bounds.height
            let aspectRatio: CGFloat = 1 // 1.25 / 1
            let width = desiredHeight * aspectRatio
            make.width.equalTo(width)
        }
        contentCellView.showAnimatedGradientSkeleton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageNews.snp.updateConstraints { make in
            let desiredHeight: CGFloat = contentView.bounds.height - 16
            let aspectRatio: CGFloat = 1 // 1.25 / 1
            let width = desiredHeight * aspectRatio
            make.width.equalTo(width)
        }
    }
    
    @MainActor
    public func setViewCell(model: GlobaleListNews) {
//        if model.pin {
//            backgroundColor = .systemPink
////            if let haveBanner = model.isBanner, haveBanner {
////                backgroundColor = .green
////            }
//        } else {
//            backgroundColor = .white
////            if let haveBanner = model.isBanner, haveBanner {
////                backgroundColor = .green
////            }
//        }
        self.showAnimatedGradientSkeleton()
        imageNews.sd_setImage(with: URL(string: model.image)) { [weak self] _, _, _, _ in
            guard let self = self else {
                return
            }
            stopSkeletonAnimation()
            hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
            lbTitleNews.text = model.title
            lbView.text = "View " + .formatNumberWithCommas(model.total_view)
            lbDate.text = model.article_date
            
            pinNews.isHidden = !model.is_pin_news
        }
    }
}
