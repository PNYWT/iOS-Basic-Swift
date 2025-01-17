//
//  CenterUIViewController.swift
//  GlobalNewsView
//
//  Created by Dev on 17/1/2568 BE.
//

import UIKit
import SnapKit

enum TypeNav {
    case none
    case NormalController
    case News
}

struct CenterUIVCModel {
    var typeNav: TypeNav = .none
    var backgroundColor: UIColor = .clear
    var fontColor: UIColor = .clear
    var pushToWhere: UIViewController?  = nil // เปิดไปไหน
    var showDataWith: CenterShowUI? = nil
}

struct CenterShowUI {
    var imageLogo: UIImage
    var titleShow: String
    var imageButton: UIImage
}

class CenterUIViewController: UIViewController {
    
    private lazy var navView: NavView = {
        let view = NavView(modelUI: modelUI)
        return view
    }()
    
    private (set) lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    
    // data Source
    private var modelUI: CenterUIVCModel! = CenterUIVCModel()
    private var isNeedCustomNav: Bool!
    init(needCustomNav: Bool = false) {
        self.isNeedCustomNav = needCustomNav
        super.init(nibName: nil, bundle: nil)
    }
    
    init(uiNavModel: CenterUIVCModel) {
        modelUI = uiNavModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupNav()
    }
    
    private func setupNav() {
        view.backgroundColor = .clear
        if isNeedCustomNav {
            view.addSubview(navView)
        }
        view.addSubview(contentView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isNeedCustomNav {
            navView.snp.makeConstraints { make in
                make.width.centerX.top.equalToSuperview()
                if view.safeAreaInsets.bottom > 20.0 {
                    make.height.equalTo(100)
                } else {
                    make.height.equalTo(80)
                }
            }
        }
        
        contentView.snp.makeConstraints { make in
            if isNeedCustomNav {
                make.top.equalTo(navView.snp.bottom)
            } else {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            }
            make.width.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
