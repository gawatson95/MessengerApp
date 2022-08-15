//
//  NotificationService.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 8/8/22.
//

import Foundation
import UserNotifications

struct NotificationService {
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Permissions granted")
            } else if let error = error {
                print ("ERROR: \(error.localizedDescription)")
            }
        }
    }

    func setNotification(recentMessage: RecentMessage) {
        let content = UNMutableNotificationContent()

        content.title = recentMessage.username
        content.subtitle = recentMessage.text
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

}
