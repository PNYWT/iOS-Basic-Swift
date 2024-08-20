//
//  UserNotificationManagement.swift
//  CallmeOni
//
//  Created by CallmeOni on 17/7/2567 BE.
//

import Foundation
import UserNotifications
import UIKit
import Combine
import Firebase
import FirebaseMessaging

class UserNotificationManagement: NormalNSObject {
    
    private (set) var isCheckNotificationStatus = PassthroughSubject<Void, Never>()
    
    override init() {
        super.init()
        setupPermission()
    }
    
    private func setupPermission() {
        UNUserNotificationCenter.current().delegate = self
        requestNotificationAuthorization()
    }
    
    private func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound, .badge]) { _, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }
    
    public func setupFCM(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in
                
            })
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
    }
}

extension UserNotificationManagement: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("Firebase registration token: \(fcmToken)")
        // ถ้ามี Service ก็ยิงตรงนี้
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension UserNotificationManagement: UNUserNotificationCenterDelegate {
    // willPresent: จะถูกเรียกเมื่อ push notification ได้รับขณะที่แอปอยู่ใน foreground (หรือกำลังเปิดอยู่).
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        UIApplication.shared.applicationIconBadgeNumber += 1
        completionHandler([.badge, .sound])
    }
    
    // didReceive: จะถูกเรียกเมื่อผู้ใช้กดที่ push notification จากที่ใดก็ตามในระบบ (ไม่ว่าแอปจะอยู่ใน foreground หรือ background)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
}
