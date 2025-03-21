//
//  TestViewController.swift
//  HeroAnimation
//
//  Created by Dev on 7/2/2568 BE.
//

import UIKit
import SnapKit

class ViewController2: UIViewController {
    
    private lazy var redCrossView: UIView = { // ต้อง id match กับ ViewController
        let view = UIView()
        view.hero.id = "redCrossView"
        view.backgroundColor = .red
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToSecondVC))
//        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var close: UIButton = {
        let view = UIButton()
        view.setTitle("Close", for: .normal)
        view.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .yellow
        view.addSubview(redCrossView)
        redCrossView.addSubview(close)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        close.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalTo(44)
        }
        redCrossView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaInsets)
        }
    }
    
    @objc private func closeAction() {
        self.dismiss(animated: true)
    }
}
