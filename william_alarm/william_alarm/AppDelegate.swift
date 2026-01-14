//
//  AppDelegate.swift
//  william_alarm
//
//  Created by William Stella on 1/14/26.
//

import UIKit
import UserNotifications
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Set self as notification delegate
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // This is called when the user taps the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier == "AlarmNotification" {
            // Notify your SwiftUI view that the alarm was tapped
            NotificationCenter.default.post(name: NSNotification.Name("AlarmTapped"), object: nil)
        }
        
        completionHandler()
    }
}
