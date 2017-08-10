//
//  AppDelegate.swift
//  NiaNow
//
//  Created by David Brownstone on 24/07/2017.
//  Copyright © 2017 David Brownstone. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        registerForPushNotifications()
        
        FirebaseApp.configure()
        
        UITabBar.appearance().barTintColor = UIColor.lightGray
        UITabBar.appearance().tintColor = UIColor.blue
        UITabBar.appearance().unselectedItemTintColor = UIColor.purple
        
        UINavigationBar.appearance().barTintColor = UIColor.lightGray
        UINavigationBar.appearance().tintColor = UIColor.blue
        
        UNUserNotificationCenter.current().delegate = self
        self.registerForPushNotifications()
        
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            let aps = notification["aps"] as! [String: AnyObject]
            
            UIApplication.shared.applicationIconBadgeNumber = 0
            let nvc = (window?.rootViewController as? UITabBarController)?.viewControllers?[0] as! UINavigationController
            let controller = nvc.topViewController as! ClassesTableViewController
            controller.handleNotification(aps)
        }
        return true
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    //app was running either in the foreground, or the background
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Print full message.
        print(userInfo)
        print("MessageId :  \(String(describing: (userInfo["gcm_message_id"])!))")
        let nvc = (window?.rootViewController as? UITabBarController)?.viewControllers?[0] as! UINavigationController
        let controller = nvc.topViewController as! ClassesTableViewController
        controller.handleNotification(userInfo["aps"] as! [String: AnyObject])
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // 1
        let userInfo = response.notification.request.content.userInfo
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        // 2
        //        if let newsItem = NewsItem.makeNewsItem(aps) {
        //            (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
        //
        //            // 3
        //            if response.actionIdentifier == viewActionIdentifier,
        //                let url = URL(string: newsItem.link) {
        //                let safari = SFSafariViewController(url: url)
        //                window?.rootViewController?.present(safari, animated: true, completion: nil)
        //            }
        //        }
        
        // 4
        completionHandler()
    }
}
