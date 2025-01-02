//
//  BannerAdViewModel.swift
//  AdmobBannerBestPractice
//
//  Created by Dev on 2/1/2568 BE.
//

import GoogleMobileAds
import Foundation
import SnapKit

class BannerAdViewModel: NSObject {
    
    // Output: State ของ Banner Ad
    var bannerViewHidden: ((Bool) -> Void)?
    private let adUnitID = "ca-app-pub-3940256099942544/2435281174"
    
    // Banner View
    private(set) var bannerView: GADBannerView = {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        return banner
    }()
    
    var bannerSize: GADAdSize {
        return GADAdSizeBanner
    }
    
    override init() {
        super.init()
        configureBannerView()
    }
    
    // กำหนดค่าเริ่มต้นให้ Banner View
    private func configureBannerView() {
        bannerView.adUnitID = adUnitID
        bannerView.delegate = self
    }
    
    // เริ่มโหลดโฆษณา
    func loadAd() {
        let request = GADRequest()
        bannerView.load(request)
    }
    
    func updateBannerAdSize(for width: CGFloat) {
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width)
    }
}

extension BannerAdViewModel: GADBannerViewDelegate {
    // MARK: - GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Ad received!")
        bannerViewHidden?(false) // แสดง Banner
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("Ad failed to load: \(error.localizedDescription)")
        bannerViewHidden?(true) // ซ่อน Banner
    }
}

