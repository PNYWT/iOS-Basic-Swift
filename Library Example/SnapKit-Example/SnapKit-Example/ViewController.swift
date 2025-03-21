//
//  ViewController.swift
//  SnapKit-Example
//
//  Created by Dev on 14/3/2567 BE.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    private lazy var mainContent:UIView! = {
        let view = UIView()
        view.backgroundColor = .blue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var subView:SubContent! = {
        let view = SubContent()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ViewController"
        view.backgroundColor = .gray
        view.addSubview(mainContent)
        mainContent.addSubview(subView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mainContent.snp.makeConstraints { make in
            make.width.height.equalTo(view.frame.width * 0.5)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(0)
            make.centerX.equalTo(view)
        }
        
        subView.snp.makeConstraints { make in
            make.width.equalTo(mainContent.snp.width).multipliedBy(0.5)
            make.height.equalTo(mainContent.snp.width).multipliedBy(0.75)
            make.center.equalTo(mainContent)
        }
    }
}

