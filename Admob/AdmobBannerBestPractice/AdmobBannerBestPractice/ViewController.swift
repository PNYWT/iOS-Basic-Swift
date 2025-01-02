//
//  ViewController.swift
//  AdmobBannerBestPractice
//
//  Created by Dev on 2/1/2568 BE.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private let viewModel = BannerAdViewModel()
    private let contentView = UIView() // View หลักสำหรับแสดงคอนเทนต์
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadAd()
    }
    
    private func setupUI() {
        view.addSubview(contentView)
        contentView.backgroundColor = .blue
        view.addSubview(viewModel.bannerView)
        
        // Layout ด้วย SnapKit
        contentView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(viewModel.bannerView.snp.top).offset(-8.0) // Space between Content and Banner
        }
        
        viewModel.bannerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(viewModel.bannerSize.size.height)
        }
    }
    
    private func bindViewModel() {
        viewModel.bannerViewHidden = { [weak self] isHidden in
            self?.viewModel.bannerView.isHidden = isHidden
            self?.updateLayoutForBannerHidden(isHidden)
        }
    }
    
    private func updateLayoutForBannerHidden(_ isHidden: Bool) {
        contentView.snp.updateConstraints { make in
            if isHidden {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(viewModel.bannerView.snp.top)
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        viewModel.updateBannerAdSize(for: size.width)
    }
}


