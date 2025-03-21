//
//  NativeAdmobViewCell.swift
//  GlobalNewsView
//
//  Created by Dev on 15/1/2568 BE.
//

import UIKit
import SnapKit
import SkeletonView

protocol NativeAdmobViewCellDelegate: AnyObject {
    func removeAtIndex(cell: NativeAdmobViewCell)
}

class NativeAdmobViewCell: UITableViewCell {
    
    weak var delegate: NativeAdmobViewCellDelegate?
    
    static let identifier = "NativeAdmobViewCell"
    
    private (set) var nativeAdmobView: SmallNativeAdView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.isUserInteractionEnabled = true
        nativeAdmobView = .init(frame: .zero)
        contentView.addSubview(nativeAdmobView)
        nativeAdmobView.snp.makeConstraints { make in
            make.height.equalToSuperview().offset(-12.0)
            make.width.equalToSuperview().offset(-32.0)
            make.centerX.centerY.equalToSuperview()
        }
        nativeAdmobView.backgroundColor = .clear
        nativeAdmobView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func setupViewNativeAdmob() {
        nativeAdmobView.loadNativeNow()
    }
}

extension NativeAdmobViewCell: SmallNativeAdViewDelegate {
    func failRemoveAll() {
        delegate?.removeAtIndex(cell: self)
    }
}

