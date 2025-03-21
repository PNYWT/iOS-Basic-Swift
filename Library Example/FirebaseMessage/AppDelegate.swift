//
//  AppDelegate.swift
//
//  Created by Dev on 6/11/2567 BE.

import Foundation
import UIKit
import FirebaseCore
import FirebaseMessaging
import FirebaseAnalytics
import SwiftyJSON
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let group = DispatchGroup()
        group.enter()
        let apnsToken = getStringFrom(deviceToken: deviceToken)
        DispatchQueue.global(qos: .default).async {
            if let encryptedToken = UserDefaults.standard.string(forKey: .tokenPushApns), let apnsTokenTmp = EncryptionApp.shared.aesDecrypt(encryptedText: encryptedToken), apnsToken == apnsTokenTmp {
                return
            }
            
            if let encryptedToken = EncryptionApp.shared.aesEncrypt(plainText: apnsToken) {
#if DEBUG
                print("deviceToken -> \(apnsToken), ----> encryptedData \(encryptedToken)")
#endif
                UserDefaults.standard.set(encryptedToken, forKey: .tokenPushApns)
            }
            group.leave()
        }
        group.notify(queue: .main) {
        // ส่ง deviceToken Apns ไปให้ Backend หากต้องการส่ง push มายัง Device โดยตรง
            if let encryptToken = UserDefaults.standard.string(forKey: .tokenPushFireBase), 
                let fcmTokenDecrypt = EncryptionApp.shared.aesDecrypt(encryptedText: encryptToken) {
                ServiceCenterViewModel.shared.registerDevice(apnsToken: apnsToken, fcmToken: fcmTokenDecrypt)
            }
        }
    }
}

extension AppDelegate {
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
