//
//  AdMobViewModel.swift
//  GlobalNewsView
//
//  Created by Dev on 15/1/2568 BE.
//

import Foundation
import UIKit
import SnapKit
import GoogleMobileAds

struct AdMobDataViewModel {
    private (set) var unitKeyBanner: String!
    private (set) var unitKeyNative: String!
    
    init(unitKeyBanner: String!, unitKeyNative: String!) {
        self.unitKeyBanner = unitKeyBanner
        self.unitKeyNative = unitKeyNative
    }
}

class AdmobViewModel {
    static var shared = AdmobViewModel()
    var adMobDataViewModel: AdMobDataViewModel!
    
    init() {
        
    }
    
    init(unitKeyBanner: String, unitKeyNative: String) {
        self.adMobDataViewModel = .init(unitKeyBanner: unitKeyBanner, unitKeyNative: unitKeyNative)
    }
}

// MARK: AbMobBannerView

import Combine
class AbMobBannerView: UIView, GADBannerViewDelegate {
    
    var updateLayout = PassthroughSubject<Void, Never>()
    
    private var sizeBanner: GADAdSize = {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return GADAdSizeFullBanner
        } else {
            return GADAdSizeBanner
        }
    }()
    
    private var bannerView: GADBannerView?
    private var unitKeyBanner: String!
    private var rootViewController: UIViewController!
    
    public func clearData() {
        bannerView = nil
        rootViewController = nil
        unitKeyBanner = nil
    }
    
    init(rootView: UIViewController) {
        self.unitKeyBanner = AdmobViewModel.shared.adMobDataViewModel?.unitKeyBanner
        self.rootViewController = rootView
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func loadBanner() {
        var adaptiveSize: GADAdSize!
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            adaptiveSize = GADAdSizeLeaderboard
        case .phone:
            adaptiveSize = GADAdSizeBanner
        default:
            break
        }
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView?.adUnitID = unitKeyBanner
        bannerView?.rootViewController = rootViewController
        bannerView?.delegate = self
        bannerView?.adSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width)
        if let haveBanner = bannerView {
            self.addSubview(haveBanner)
            haveBanner.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.centerX.equalToSuperview()
            }
        }
        bannerView?.load(GADRequest())
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
#if DEBUG
        print("Banner Frame: \(bannerView.frame)")
        print("Ad Size: \(bannerView.adSize.size)")
        bannerView.backgroundColor = .lightGray.withAlphaComponent(0.2)
#endif
        
        self.snp.updateConstraints { make in
            guard let haveSuperView = self.superview else {
                return
            }
            make.height.equalTo(bannerView.frame.height)
            make.bottom.equalTo(haveSuperView.snp.bottom).offset(rootViewController.view.safeAreaInsets.bottom >= 20 ? -20 : 0)
        }
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        #if DEBUG
        print("bannerView didFailToReceiveAdWithError \(error.localizedDescription)")
        #endif
        self.subviews.forEach { view in
            view.removeFromSuperview()
        }
        self.snp.updateConstraints { make in
            make.height.equalTo(0.0)
            make.bottom.equalTo(rootViewController.view.snp.bottom).offset(0)
        }
    }
}

// MARK: SmallNativeAdView
protocol SmallNativeAdViewDelegate: AnyObject {
    func failRemoveAll()
}

class SmallNativeAdView: UIView {
    
    weak var delegate: SmallNativeAdViewDelegate?
    
    private lazy var nativeView: GADNativeAdView = {
        let nibView = Bundle.main.loadNibNamed("SmallNativeAdView", owner: nil, options: nil)?.first
        guard let nativeAdView = nibView as? GADNativeAdView else {
            return GADNativeAdView()
        }
        nativeAdView.alpha = 1.0
        return nativeAdView
    }()
    
    private (set) var adLoaderNative: GADAdLoader?
    
    private var keyAdmob: String!
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(nativeView)
        nativeView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        keyAdmob = AdmobViewModel.shared.adMobDataViewModel?.unitKeyNative
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var addToCenter: Bool = false
    public func loadNativeNow() {
//        guard let vc = getOwningViewController() else {
//            return
//        }
        // rootViewController ถ้ามีปัญหาก็ใส่เพิ่ม
        let videoOptions: GADVideoOptions = GADVideoOptions.init()
        adLoaderNative = GADAdLoader(adUnitID: keyAdmob, rootViewController: nil,
                                     adTypes: [ .native ], options: [videoOptions])
        
        adLoaderNative?.delegate = self
        let request: GADRequest = GADRequest.init()
        adLoaderNative?.load(request)
    }
}

extension SmallNativeAdView: GADAdLoaderDelegate, GADNativeAdLoaderDelegate {
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        print("\(adLoader) didfinishloading...")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: any Error) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
        adLoaderNative = nil
        subviews.forEach { view in
            view.removeFromSuperview()
        }
        delegate?.failRemoveAll()
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        print("native admob didreceive")
        (nativeView.headlineView as? UILabel)?.text = nativeAd.headline // check
        nativeView.mediaView?.mediaContent = nativeAd.mediaContent
        if let mediaView = nativeView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
            mediaView.snp.remakeConstraints { make in
                make.height.equalTo(mediaView.snp.width).multipliedBy(1 / nativeAd.mediaContent.aspectRatio)
            }
            mediaView.contentMode = .scaleAspectFit
        }
        
        (nativeView.advertiserView as? UILabel)?.text = nativeAd.advertiser // check
        nativeView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        (nativeView.storeView as? UILabel)?.text = nativeAd.store
        nativeView.storeView?.isHidden = nativeAd.store == nil
        
        (nativeView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        (nativeView.callToActionView as? UIButton)?.titleLabel?.adjustsFontSizeToFitWidth = true
        nativeView.callToActionView?.isHidden = nativeAd.callToAction == nil
        if let btnIsHidden = nativeView.callToActionView?.isHidden, !btnIsHidden {
            nativeView.callToActionView?.layer.cornerRadius = 15
            nativeView.callToActionView?.layer.masksToBounds = true
        }
        nativeView.callToActionView?.isUserInteractionEnabled = false
        nativeView.nativeAd = nativeAd
        nativeView.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.9725490196, blue: 0.7921568627, alpha: 1)
        nativeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        nativeView.setNeedsLayout()
        UIView.animate(withDuration: 1.0, animations: { [weak self] in
            self?.nativeView.alpha = 1.0
        })
    }
}

