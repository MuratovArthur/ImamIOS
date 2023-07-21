//
//  NotificationManager.swift
//  ImamAI
//
//  Created by Muratov Arthur on 21.07.2023.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    
    func scheduleNotificationIfNeeded(prayerTime: String, isMuted: Bool, prayerTimes: [String: String]) {
        // Check if the notification is enabled (not muted)
        guard !isMuted else {
            // If muted, cancel any previously scheduled notifications for this prayer time
            cancelNotification(for: prayerTime)
            return
        }
        
        // Get the date components for the prayer time using the prayerTimes parameter
        let prayerTimeComponents = prayerTimes[prayerTime]?.split(separator: ":")
            .compactMap { Int($0) }
            .suffix(2)
        
        guard let hour = prayerTimeComponents?.first, let minute = prayerTimeComponents?.last else {
            return
        }
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let content = UNMutableNotificationContent()
        content.title = "It's time to pray"
        content.body = prayerTime
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: prayerTime, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification for \(prayerTime): \(error.localizedDescription)")
            } else {
                let formattedHour = String(format: "%02d", dateComponents.hour ?? 0)
                let formattedMinute = String(format: "%02d", dateComponents.minute ?? 0)
                print("Notification scheduled for \(prayerTime) at \(formattedHour):\(formattedMinute)")
            }
        }
    }
    
    
    func cancelNotification(for prayerTime: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [prayerTime])
    }
}



class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Handle the foreground notification here and display an appropriate alert or user interface
        
        // Customize the presentation options to show banners, play sound, or update the badge.
        var presentationOptions: UNNotificationPresentationOptions = [.badge, .sound]
        
        // Show banners even when the app is in the foreground and the notification center is open.
        if UIApplication.shared.applicationState == .active {
            presentationOptions.insert(.banner)
        }
        
        completionHandler(presentationOptions)
    }
}
