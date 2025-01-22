//
//  NavView.swift
//  GlobalNewsView
//
//  Created by Dev on 17/1/2568 BE.
//

import UIKit
import SnapKit

class NavView: UIView {
    
    private lazy var anyButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var imageLogo: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var lbTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.font = .systemFont(ofSize: 24, weight: .bold)
        view.textColor = .white
        view.backgroundColor = .clear
        return view
    }()
    
    private var modelUI: CenterUIVCModel!
    init(modelUI: CenterUIVCModel) {
        super.init(frame: .zero)
        self.modelUI = modelUI
        backgroundColor = modelUI.backgroundColor
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        switch modelUI.typeNav {
        case .NormalController:
            normalTypeView()
        case .News:
            newsTypeView()
        case .none:
            break
        }
    }
    
    private func normalTypeView() {
        anyButton.addTarget(self, action: #selector(actionNormal), for: .touchUpInside)
        anyButton.isUserInteractionEnabled = modelUI.pushToWhere != nil ? true: false
        if let haveImage = modelUI.showDataWith?.imageButton {
            anyButton.setImage(haveImage, for: .normal)
        }
        if let haveLogo = modelUI.showDataWith?.imageLogo {
            imageLogo.image = haveLogo
        }
        if let titleShow = modelUI.showDataWith?.titleShow {
            lbTitle.text = titleShow
        }
        lbTitle.textColor = modelUI.fontColor
        
        addSubview(anyButton)
        anyButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8.0)
            make.width.height.equalTo(44.0)
            make.trailing.equalToSuperview().offset(-8.0)
        }
        addSubview(imageLogo)
        imageLogo.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8.0)
            make.leading.equalToSuperview().offset(8.0)
            make.width.height.equalTo(50.0)
        }
        addSubview(lbTitle)
        lbTitle.snp.makeConstraints { make in
            make.centerY.equalTo(imageLogo)
            make.leading.equalTo(imageLogo.snp.trailing).offset(4.0)
        }
    }
    
    private func newsTypeView() {
        anyButton.addTarget(self, action: #selector(actionNews), for: .touchUpInside)
        anyButton.tintColor = .black
        lbTitle.font = .systemFont(ofSize: 16, weight: .bold)
        if let haveImage = modelUI.showDataWith?.imageButton {
            anyButton.setImage(haveImage, for: .normal)
        }
        if let haveLogo = modelUI.showDataWith?.imageLogo {
            imageLogo.image = haveLogo
        }
        if let titleShow = modelUI.showDataWith?.titleShow {
            lbTitle.text = titleShow
        }
        lbTitle.textColor = modelUI.fontColor
        
        addSubview(anyButton)
        anyButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-4.0)
            make.leading.equalToSuperview().offset(4.0)
            make.width.height.equalTo(44.0)
        }
        addSubview(imageLogo)
        imageLogo.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-4.0)
            make.leading.equalTo(anyButton.snp.trailing).offset(4.0)
            make.width.height.equalTo(44.0)
        }
        addSubview(lbTitle)
        lbTitle.snp.makeConstraints { make in
            make.centerY.equalTo(imageLogo)
            make.leading.equalTo(imageLogo.snp.trailing).offset(4.0)
            make.trailing.equalToSuperview().offset(-4.0)
        }
    }
    
    @objc private func actionNormal() {
        guard let goWhere = modelUI.pushToWhere else {
            return
        }
        guard let vc = self.getViewController() else {
            return
        }
        vc.navigationController?.pushViewController(goWhere, animated: true)
    }
    
    @objc private func actionNews() {
        guard let vc = self.getViewController() else {
            return
        }
        vc.navigationController?.popViewController(animated: true)
    }
}
