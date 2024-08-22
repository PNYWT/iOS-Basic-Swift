//
//  UserNotificationManagement.swift
//  CallmeOni
//
//  Created by CallmeOni on 17/7/2567 BE.
//

import Foundation
import UIKit
import Combine
import Firebase
import FirebaseMessaging
import FirebaseAnalytics
import UserNotifications

class UserNotificationManagement: NormalNSObject {
    
    init(application: UIApplication) {
        super.init()
        setupFCM(application)
    }
    
    private func setupFCM(_ application: UIApplication) {
        FirebaseApp.configure()
        Analytics.logEvent("app_start", parameters: [:])
        Analytics.setUserProperty(UIDevice.current.systemName, forName: "user_os")
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { _, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) { // Push Message 1
//        let deviceTokenString = deviceToken.map {
//            String(format: "%02.2hhx", $0)
//        }.joined()
//        print("deviceTokenString -> \(deviceTokenString)")
        Messaging.messaging().apnsToken = deviceToken
        // ถ้ามี Service ก็ยิงตรงนี้
    }
}

extension UserNotificationManagement: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) { // Push Message 2
        guard let fcmToken = fcmToken else { return }
        if ConfigRelease.showLogConsole {
            print("Firebase registration token: \(fcmToken)")
        }
    }
}

extension UserNotificationManagement: UNUserNotificationCenterDelegate {
    
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
