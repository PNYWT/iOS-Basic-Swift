//
//  ViewController.swift
//  TestScrollView
//
//  Created by Dev on 17/6/2567 BE.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private lazy var cltvMain: CltvMain = {
        let view = CltvMain(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addCltv()
//        setUpHeader()
//        setUpTableView()
    }
    
    private func addCltv() {
        view.addSubview(cltvMain)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cltvMain.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
}
