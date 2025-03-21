//
//  NewsTableViewCell.swift
//  GlobalNewsView
//
//  Created by Dev on 10/1/2568 BE.
//

import UIKit
import SnapKit

class NewsTableViewCell: UITableViewCell {
    
    private lazy var imageNews: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.makeCornerRadius(radius: 8.0, needMasksToBounds: true)
        return view
    }()
    
    private lazy var imageEyes: UIImageView = {
        let view = UIImageView(image: UIImage(named: "ic_newsView"))
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var lbTitleNews: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        return view
    }()
    
    private lazy var lbView: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private lazy var lbDate: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private lazy var imageUnderline: UIImageView = {
        let view = UIImageView(image: UIImage(named: "ic_underLine"))
        view.contentMode = .scaleToFill
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
    
    private func commonInit() {
        contentView.addSubview(imageNews)
        contentView.addSubview(lbTitleNews)
        contentView.addSubview(imageEyes)
        contentView.addSubview(lbView)
        contentView.addSubview(lbDate)
        contentView.addSubview(imageUnderline)

        imageNews.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8.0)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().offset(-16.0)
            let desiredWidth: CGFloat = contentView.bounds.height
            let aspectRatio: CGFloat = 303 / 265
            let width = desiredWidth * aspectRatio
            make.width.equalTo(width)
        }
        
        lbTitleNews.snp.makeConstraints { make in
            make.leading.equalTo(imageNews.snp.trailing).offset(8.0)
            make.top.equalTo(imageNews.snp.top)
            make.trailing.equalToSuperview().offset(-8.0)
        }
        
        imageEyes.snp.makeConstraints { make in
            make.leading.equalTo(imageNews.snp.trailing).offset(8.0)
            make.bottom.equalTo(imageNews.snp.bottom)
            make.width.height.equalTo(15.0)
        }
        
        lbView.snp.makeConstraints { make in
            make.leading.equalTo(imageEyes.snp.trailing).offset(4.0)
            make.centerY.equalTo(imageEyes)
        }
        
        lbDate.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8.0)
            make.centerY.equalTo(imageEyes)
        }
        
        imageUnderline.snp.makeConstraints { make in
            make.width.centerX.bottom.equalToSuperview()
            make.height.equalTo(2.0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageNews.snp.updateConstraints { make in
            let desiredWidth: CGFloat = contentView.bounds.height
            let aspectRatio: CGFloat = 303 / 265
            let width = desiredWidth * aspectRatio
            make.width.equalTo(width)
        }
    }
    
//    public func setView(model: NewsModel) {
//        if model.pin {
//            backgroundColor = .bgTertiary
//            if let haveBanner = model.isBanner, haveBanner {
//                backgroundColor = .green
//            }
//        } else {
//            backgroundColor = .white
//            if let haveBanner = model.isBanner, haveBanner {
//                backgroundColor = .green
//            }
//        }
//        imageNews.sd_setImage(with: URL(string: model.image))
//        lbTitleNews.text = model.title
//        lbView.text = .formatNumberWithCommas(model.total_view)
//        lbDate.text = model.artide_date
//    }
}
