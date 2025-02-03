//
//  AdmobViewModel.swift
//  DemoUMP
//
//  Created by Dev on 22/1/2568 BE.
//

import Foundation
import AppTrackingTransparency
import UserMessagingPlatform
import UIKit
import GoogleMobileAds
import SnapKit

@MainActor
class AdmobViewModel: NSObject {
    
    var bannerView: GADBannerView?
    private var viewController: UIViewController!
    
    init(vc: UIViewController) {
        self.viewController = vc
        super.init()
    }
    
    public func callPermission(completion: @escaping () -> Void) {
        requestUMPConsent {
            self.requestATTracking()
            completion()
        }
    }
    
    private func requestATTracking() {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { [weak self] status in
            if status == .authorized {
                // authorized
            }
            self?.callAdmobBanner()
        })
    }
    
    private func requestUMPConsent(completion: @escaping () -> Void) {
        let parameters = UMPRequestParameters()
        parameters.tagForUnderAgeOfConsent = false // App สำหรับ kid หรือไม่
 
        #if DEBUG
        UMPConsentInformation.sharedInstance.reset()
        let debugSettings = UMPDebugSettings()
        debugSettings.testDeviceIdentifiers =  ["F8BB1C28-BAE8-11D6-9C31-00039315CD46"]
        debugSettings.geography = .EEA
        parameters.debugSettings = debugSettings
        #endif
        
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) { error in
            if let error = error {
                print("UMP Error: \(error.localizedDescription)")
                completion()
                return
            }
            Task {
                do {
                    try await UMPConsentForm.loadAndPresentIfRequired(from: nil)
                    completion()
                } catch {
                    print("UMP Form Load Error: \(error.localizedDescription)")
                    completion()
                }
            }
        }
    }
    
    public func callAdmobBanner() {
        if UMPConsentInformation.sharedInstance.canRequestAds {
            print(UMPConsentInformation.sharedInstance.canRequestAds)
            let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width)
            bannerView = GADBannerView(adSize: adaptiveSize)
            bannerView?.adUnitID = "ca-app-pub-3940256099942544/2435281174"
            bannerView?.rootViewController = viewController
            bannerView?.delegate = self
            viewController.view.addSubview(bannerView!)
            bannerView?.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-16.0)
            }
            bannerView?.load(GADRequest())
        } else {
            bannerView?.removeFromSuperview()
        }
    }
}

extension AdmobViewModel: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("bannerViewDidReceiveAd")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        bannerView.removeFromSuperview()
    }
}
