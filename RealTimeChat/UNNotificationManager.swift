//
//  UNNotificationManager.swift
//  RealTimeChat
//
//  Created by Solji Kim on 31/05/2019.
//  Copyright © 2019 Doyeong Kim. All rights reserved.
//

import UIKit
import UserNotifications

class UNNotificationManager: UIViewController {
    
    enum Identifier {
        static let category = "category"
        
        static let newMsgRequest = "newMsgRequest"
        
        static let checkAction = "checkAction"
        static let readAction = "readAction"
        static let textInputAction = "textInputAction"
    }
    
    let center = UNUserNotificationCenter.current()
    
    func register() {
        let options: UNAuthorizationOptions = [.alert, .badge]
        
        center.delegate = self
        
        center.requestAuthorization(options: options) { (isGranted, error) in
            guard isGranted else {
                print("Not granted")
                return self.requestAlertNotification()
            }
            print("Granted")
            self.setupNotificationCategories()
        }
    }

    func requestAlertNotification() {
        guard let settingUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        DispatchQueue.main.async {
            UIApplication.shared.open(settingUrl)
        }
    }
    
    func setupNotificationCategories() {
        
        let checkAction = UNNotificationAction(
            identifier: Identifier.checkAction,
            title: "보기",
            options: [.foreground]
        )
        
//        let readAction = UNNotificationAction(
//            identifier: Identifier.readAction,
//            title: "읽음",
//            options: []
//        )
        
//        let textInputAction = UNTextInputNotificationAction(
//            identifier: Identifier.textInputAction,
//            title: "답장",
//            options: [.authenticationRequired],
//            textInputButtonTitle: "보내기",
//            textInputPlaceholder: "메세지를 입력하세요"
//        )
        
        let category = UNNotificationCategory(
            identifier: Identifier.category,
            actions: [checkAction],
            intentIdentifiers: [],
            options: [.customDismissAction])  // 알림 떳을때 밑으로 내리면 (x) 창닫기 누르면 노티에 반응을 전달할수잇음.
        
        center.setNotificationCategories([category])
    }

    func triggerMsgNotification(with title: String, msg message: String) {
        
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = Identifier.category
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: message, arguments: nil)
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: Identifier.newMsgRequest,
            content: content,
            trigger: nil)
        
        center.add(request)
        
    }
    
}

// MARK: - UNUserNotificationCenterDelegate

extension UNNotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("\n-------- [ willPresent Notification ] --------\n")
        
        print(notification)
        completionHandler([.alert, .sound])

    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("\n-------- [ didReceive notification response ] --------\n")
    }
}
