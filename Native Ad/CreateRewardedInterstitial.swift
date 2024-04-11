//
//  File.swift
//  PlayPlayPlus
//
//  Created by Dev on 21/2/2567 BE.
//

import Foundation
import GoogleMobileAds
import SwiftyJSON

/*
 custom_data
 - order_no
 - response_id
 - pubid
 - vid
 - user_uid
 - user_id
 */

class CreateRewardedInterstitial:NSObject{
    
    var eventCloseRewardAd: ((_ withStatusUnlock:Bool)->Void)?
    var eventShowAlertError: ((_ errString:String)->Void)?
    
    private var rewardedGADRewardedAd: GADRewardedAd?
    private let realKey = "ca-app-pub-2916822186662378/6555024195"
    private var keyRewardInterstitial:String!
    
    
    private var responseIden:String?
    private var amounts:String?
    private var pubid:String?
    
    private var orderNoFromStartAd:String?
    private var statusUnlock = false
    
    override init() {
        super.init()
        keyRewardInterstitial = ConfigApp.isAdmobRealKey ? realKey : "ca-app-pub-3940256099942544/6978759866"
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "ee67ed4dff78fbd7256352c4c1d52a12"]
    }
    
    func requestRewardedInterstitial(completionLoad:(()->Void)? = nil)->Void{
        clearData()
        GADRewardedAd.load(withAdUnitID:keyRewardInterstitial,
                                       request: GADRequest()) { ad, error in
            if let _ = error {
//                print("Failed to load rewarded ad with error: \(error?.localizedDescription)")
                self.eventShowAlertError?(error?.localizedDescription ?? Language.getLocalLanguage(string: "sys_msg_adsnotready"))
                return
            }
            self.rewardedGADRewardedAd = ad
            self.rewardedGADRewardedAd?.fullScreenContentDelegate = self
            
            if let reward = self.rewardedGADRewardedAd{
                if let responseInfo:[String:Any] = reward.responseInfo.dictionaryRepresentation["Loaded Adapter Response"] as? [String:Any], let adUnitMapping:[String:Any] = responseInfo["AdUnitMapping"] as? [String:Any], let pubid = adUnitMapping["pubid"] {
                    self.pubid = "\(pubid)"
                }
                self.responseIden = reward.responseInfo.responseIdentifier
                self.amounts = "\(reward.adReward.amount)"
            }
            completionLoad?()
        }
    }
    
    func checkAdIsReady(completion:((_ success:Bool)->Void))->Void{
        guard let _ = rewardedGADRewardedAd else{
            requestRewardedInterstitial()
            eventShowAlertError?(Language.getLocalLanguage(string: "sys_msg_adsnotready"))
            completion(false)
            return
        }
        completion(true)
    }
    
    func showAdReward(withController vc:UIViewController, vid:String){
        guard let rewardedInterstitialAd = rewardedGADRewardedAd else {
            eventShowAlertError?(Language.getLocalLanguage(string: "sys_msg_adsnotready"))
            return
        }
        
        //ยิง start watch ก่อน present
        var parameter:[String:String] = ["vid":vid]
        if let response_id = responseIden{
            parameter["response_id"] = response_id
        }
        
        if let amount = amounts{
            parameter["amount"] = amount
        }
        
        if let pubid = pubid{
            parameter["pubid"] = pubid
        }
        
        ConfigCustomService.centerPostService(withURL: ConfigDiscoverURL.actionBuyWithAd(), withParameter: parameter) { [weak self] checkRet, responseData in
            guard let self = self else {
                return
            }
            if checkRet.ret == RetType.RET_SUCCESS{
                guard let object = try? JSON(data: responseData).dictionaryObject else{
                    return
                }
                if let data:[String:Any] = object["data"] as? [String : Any], let order_no = data["order_no"]{
                    parameter["order_no"] = "\(order_no)"
                }
                
                
                var parameterGAD = parameter
                parameterGAD["user_uid"] = ConfigAccount.shared.user_uid
                parameterGAD["user_id"] = ConfigAccount.shared.user_id
                parameterGAD["version"] = ConfigAppInfo.versionApp()
                
                if ConfigApp.isAdmobRealKey{
                    parameterGAD["server_type"] = "1"
                }else{
                    parameterGAD["server_type"] = "0"
                }
                /*
                 order_no -> check
                 user_uid -> Check
                 vid -> check
                 amount -> check
                 user_id -> check
                 response_id -> check
                 pubid -> check
                 {"user_uid":"pp29d3c6515d975dfae9af5756ee01aa85","order_no":"AD1709622813279243948","amount":"1","vid":"7368","response_id":"G8bmZfe-AcO4jMwPlsa3cA","pubid":"ca-app-pub-2916822186662378\/6555024195\/cak=no_cache&cadc=94&caqid=G8bmZelf0ZH1_A_7zpTQCw","ref_account":"ml@20250164","user_id":"952070661"}
                 
                 ถ้าตัด pubid ออก
                 {"vid":"7368","order_no":"AD1709624145354461812","amount":"1","user_uid":"pp29d3c6515d975dfae9af5756ee01aa85","response_id":"TsvmZY6tCfOArtoP88G34Ag","user_id":"952070661"}
                 */
//                parameterGAD.removeValue(forKey: "pubid")
                let jsonObj = JSON(parameterGAD)
                guard let stringJSON = jsonObj.rawString(.utf8, options: []) else{
                    return
                }
                
                let options = GADServerSideVerificationOptions()
                options.customRewardString = stringJSON
                rewardedInterstitialAd.serverSideVerificationOptions = options
                
                rewardedInterstitialAd.present(fromRootViewController: vc) {
                    ConfigCustomService.centerPostService(withURL: ConfigDiscoverURL.resultBuyWithAd(), withParameter: parameter) { checkRet, responseData in
                        if checkRet.ret == RetType.RET_SUCCESS{
                            self.statusUnlock = true
                        }else{
                            self.eventShowAlertError?(checkRet.code)
                        }
                    } postFail: { withError in }
                }
            }else{
                self.eventShowAlertError?(checkRet.code)
            }
        } postFail: { withError in }
    }
    
    private func clearData(){
        responseIden = nil
        amounts = nil
        pubid = nil
    }
}

extension CreateRewardedInterstitial:GADFullScreenContentDelegate{
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
            self.eventCloseRewardAd?(self.statusUnlock)
            self.rewardedGADRewardedAd = nil
        }
    }
}
