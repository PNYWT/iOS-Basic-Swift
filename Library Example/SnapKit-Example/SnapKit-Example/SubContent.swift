//
//  SubContent.swift
//  SnapKit-Example
//
//  Created by Dev on 14/3/2567 BE.
//

import Foundation
import UIKit


class SubContent:UIView{
    
    private lazy var contentView:UIView! = {
        let view = UIView()
        view.backgroundColor = .green
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentView2:UIView! = {
        let view = UIView()
        view.backgroundColor = .yellow
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        addSubview(contentView)
        addSubview(contentView2)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        /*
         NSLayoutConstraint.activate([
             contentView.widthAnchor.constraint(equalToConstant: self.frame.width * 0.50),
             contentView.heightAnchor.constraint(equalToConstant: self.frame.width * 0.75),
             contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
             contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
         ])
         */
        
        contentView.widthAnchor.constraint(equalToConstant: self.frame.width * 0.50).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: self.frame.width * 0.75).isActive = true
        contentView.topAnchor.constraint(equalTo:  self.topAnchor, constant: 8).isActive = true
        contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        
        /*
         contentView.snp.makeConstraints { make in
        //            make.width.equalTo(self.snp.width).multipliedBy(0.5)
             make.width.equalTo(self.frame.width * 0.5)
             make.height.equalTo(self.snp.width).multipliedBy(0.75)
             make.top.equalTo(self.snp.topMargin)
             make.centerX.equalTo(self.snp_centerXWithinMargins)
         }
         */
        
        contentView2.snp.makeConstraints { make in
            make.width.equalTo(self.snp.width).multipliedBy(0.75)
            make.height.equalTo(self.snp.width).multipliedBy(0.50)
            make.top.equalTo(contentView.snp.bottom).offset(8)
            make.centerX.equalTo(contentView.snp_centerXWithinMargins)
        }
    }
}
