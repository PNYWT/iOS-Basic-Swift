//
//  PushNotificationViewModel.swift
//
//  Created by Dev on 11/11/2567 BE.
//

import Foundation
import Firebase
import FirebaseAnalytics
import FirebaseMessaging
import UserNotifications
import Alamofire

class PushNotificationViewModel: NormalNSObject {
    
    override init() {
        super.init()
    }
    
    public func setupUNNotification(completion: @escaping() -> Void) {
        let center = UNUserNotificationCenter.current()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        center.delegate = self
#if DEBUG
        print("AppDelegate.getIMEI -> \(AppDelegate.getIMEI)")
#endif
        Analytics.setAnalyticsCollectionEnabled(true)
        Analytics.logEvent("app_start_iOS", parameters: [
            "IMEI": AppDelegate.getIMEI as NSObject
        ])
        center.requestAuthorization(options: [.alert, .badge, .sound]) { status , error in
            if let error = error {
                print("Notification authorization error: \(error)")
                completion()
            } else {
                completion()
            }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

extension PushNotificationViewModel: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            UserDefaults.standard.set(nil, forKey: .tokenPushFireBase)
            return
        }
        #if DEBUG
        print("Firebase didReceiveRegistrationToken: \(fcmToken)")
        #endif
        // กรณี token fcm เปลี่ยน
        if let encryptToken = UserDefaults.standard.string(forKey: .tokenPushFireBase),
           let fcmTokenDecrypt = EncryptionApp.shared.aesDecrypt(encryptedText: encryptToken), fcmTokenDecrypt != fcmToken {
            if let encryptedToken = EncryptionApp.shared.aesEncrypt(plainText: fcmToken) {
                UserDefaults.standard.set(encryptedToken, forKey: .tokenPushFireBase)
            }
            if let apnsToken = UserDefaults.standard.string(forKey: .tokenPushApns),
               let apnsTokenDecrypt = EncryptionApp.shared.aesDecrypt(encryptedText: apnsToken) {
                ServiceCenterViewModel.shared.registerDevice(apnsToken: apnsTokenDecrypt, fcmToken: fcmToken)
            }
        } else {
            if let encryptedToken = EncryptionApp.shared.aesEncrypt(plainText: fcmToken) {
                UserDefaults.standard.set(encryptedToken, forKey: .tokenPushFireBase)
            }
            /*
             จัดการต่อใน AppDelegate didRegisterForRemoteNotificationsWithDeviceToken ส่งข้อมูลไป Server
             */
        }
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        if fcmToken.isEmpty {
            UserDefaults.standard.set(nil, forKey: .tokenPushFireBase)
            return
        }
#if DEBUG
        print("Firebase didRefreshRegistrationToken: \(fcmToken)")
#endif
        UserDefaults.standard.set(fcmToken, forKey: .tokenPushFireBase)
    }
}

extension PushNotificationViewModel: UNUserNotificationCenterDelegate {
    // willPresent: จะถูกเรียกเมื่อ push notification ได้รับขณะที่แอปอยู่ใน foreground (หรือกำลังเปิดอยู่).
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("willPresent")
        UIApplication.shared.applicationIconBadgeNumber += 1
        completionHandler([.badge, .sound])
    }
    
    // didReceive: จะถูกเรียกเมื่อผู้ใช้กดที่ push notification จากที่ใดก็ตามในระบบ (ไม่ว่าแอปจะอยู่ใน foreground หรือ background)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("didReceive")
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
}
