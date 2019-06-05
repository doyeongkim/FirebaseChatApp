//
//  AppDelegate.swift
//  RealTimeChat
//
//  Created by Solji Kim on 10/05/2019.
//  Copyright © 2019 Doyeong Kim. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let notiManager = UNNotificationManager()
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        notiManager.register()
        return true
    }
}

