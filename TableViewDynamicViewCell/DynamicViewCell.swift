//
//  DynamicLabelCell.swift
//
//  Created by Dev on 19/11/2567 BE.
//  Copyright © 2567 BE OHLALA Online. All rights reserved.
//

import UIKit
import SnapKit

// MARK: DynamicLabelCell
class DynamicLabelCell: UITableViewCell {
    
    private let label = LabelView(color: .lbPrimaryDetail, textAlignment: .left, font: .customFont(.PrimaryDetail, size: 18))
    
    private lazy var imageUnderline: UIImageView = {
        let view = UIImageView(image: UIImage(named: "ic_underLine"))
        view.contentMode = .scaleToFill
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        label.numberOfLines = 0
        contentView.addSubview(label)
        contentView.addSubview(imageUnderline)
        setupConstraints()
    }
    
    private func setupConstraints() {
        label.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.bottom.trailing.equalToSuperview().offset(-16)
        }
        
        imageUnderline.snp.makeConstraints { make in
            make.width.centerX.bottom.equalToSuperview()
            make.height.equalTo(2.0)
        }
    }
    
    public func configure(with text: String) {
        label.text = text
    }
}

// MARK: DynamicPrayViewCell
protocol DynamicPrayViewCellDelegate: AnyObject {
    func playAudioWith(indexPath: IndexPath, isPlay: Bool)
    func saveFav(indexPath: IndexPath, isSave: Bool)
}

class DynamicPrayViewCell: UITableViewCell {
    
    weak var delegate: DynamicPrayViewCellDelegate?
    
    private lazy var lbTitle: LabelView = {
        let view = LabelView(color: .lbPrimaryDetail, textAlignment: .left, font: .customFont(.PrimaryDetail, size: 18))
        view.numberOfLines = 0
        return view
    }()
    
    private (set) lazy var btnFav: UIButton = {
        let view = UIButton()
        view.setBackgroundImage(UIImage(named: "ic_Dfav"), for: .normal)
        view.setBackgroundImage(UIImage(named: "ic_Sfav"), for: .selected)
        view.addTarget(self, action: #selector(actionFav(sender:)), for: .touchUpInside)
        view.backgroundColor = .bgTertiary
        view.makeCornerRadius(radius: 8.0, needMasksToBounds: true)
        return view
    }()
    
    private (set) lazy var btnPlay: UIButton = {
        let view = UIButton()
        view.setBackgroundImage(UIImage(named: "ic_voice"), for: .normal)
        view.addTarget(self, action: #selector(actionPlay(sender:)), for: .touchUpInside)
        view.backgroundColor = .bgTertiary
        view.makeCornerRadius(radius: 8.0, needMasksToBounds: true)
        return view
    }()
    
    private lazy var imageUnderline: UIImageView = {
        let view = UIImageView(image: UIImage(named: "ic_underLine"))
        view.contentMode = .scaleToFill
        return view
    }()

    private var indexPathCell: IndexPath!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(lbTitle)
        contentView.addSubview(btnFav)
        contentView.addSubview(btnPlay)
        contentView.addSubview(imageUnderline)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        lbTitle.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.trailing.equalToSuperview().offset(-88)
        }
        
        btnFav.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-4.0)
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        
        btnPlay.snp.makeConstraints { make in
            make.trailing.equalTo(btnFav.snp.leading).offset(-4.0)
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        
        imageUnderline.snp.makeConstraints { make in
            make.width.centerX.bottom.equalToSuperview()
            make.height.equalTo(2.0)
        }
    }
    
    public func setupView(model: AllParyRow, indexPath: IndexPath) {
        indexPathCell = indexPath
        lbTitle.text = String(format: "%d. %@", indexPath.row + 1, model.prayTitle)
        btnFav.isSelected = model.isFav
    }
}

// MARK: DynamicPrayViewCell - Action
extension DynamicPrayViewCell {
    
    @objc private func actionPlay(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.alpha = 0.5
        } else {
            sender.alpha = 1.0
        }
        delegate?.playAudioWith(indexPath: indexPathCell, isPlay: sender.isSelected)
    }
    
    @objc private func actionFav(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.saveFav(indexPath: indexPathCell, isSave: sender.isSelected)
    }
}
