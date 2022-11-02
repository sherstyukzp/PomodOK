//
//  NotificationManager.swift
//  PomodOK
//
//  Created by Ярослав Шерстюк on 10.07.2022.
//  Copyright © 2022 Ярослав Шерстюк. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationManager {
    // MARK: - Requesting Notification Permission
    
    private var notificationCenter =  UNUserNotificationCenter.current()
    
    func registerLocal() {
        
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("✅ Yay! registerLocal")
            } else {
                print("✅ D'oh registerLocal")
            }
        }
    }
    
    // MARK: - Notification Request Identifier
    func addNotification(identifier: String, titleNotification: String, subtitleNotification: String, bodyNotification: String, timeInterval: TimeInterval) {
        
        let addRequest = { [weak self] in
            let content = UNMutableNotificationContent()
            
            content.title = titleNotification
            content.subtitle = subtitleNotification
            content.body = bodyNotification
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            self?.notificationCenter.add(request)
        }
        notificationCenter.getNotificationSettings { [weak self] settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                self?.notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                        print("✅ addRequest")
                    } else {
                        print("D'oh")
                    }
                }
            }
        }
        print("✅ addNotification \(identifier)")
    }
    
    // MARK: - Remove UNNotificationRequest From UNUserNotificationCenter
    /* To remove UNNotificationRequest from a UNUserNotificationCenter we will need to use the removePendingNotificationRequests() function that accepts an array of notification request identifiers. To remove a single notification, simply provide a single identifier in the list.
     */
    func deleteNotification(identifier: String) {
        
        notificationCenter.getPendingNotificationRequests { (notificationRequests) in
            var identifiers: [String] = []
            for notification:UNNotificationRequest in notificationRequests {
                if notification.identifier == identifier {
                    identifiers.append(notification.identifier)
                }
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
        print("✅ deleteNotification \(identifier)")
        
    }
    
    // MARK: - Remove Pending Notification Requests
    func removeAllPendingNotificationRequests() {
        notificationCenter.removeAllPendingNotificationRequests()
        print("✅ removeAllPendingNotificationRequests")
    }
    
    // MARK: - Remove Delivered Notification Requests
    func removeAllDeliveredNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
        print("✅ removeAllDeliveredNotifications")
    }
    
    // MARK: - Read All Delivered Notifications
    func getDeliveredNotifications() {
        notificationCenter.getDeliveredNotifications { (notifications) in
            for notification:UNNotification in notifications {
                print("✅ getDeliveredNotifications \(notification.request.identifier)")
            }
        }
    }
    
    
}
