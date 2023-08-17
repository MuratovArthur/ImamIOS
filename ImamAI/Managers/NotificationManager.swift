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
    
    var prayerTimes: [PrayerTime] = []
    
    var isMutedArray: [Bool] {
        UserDefaultsManager.shared.getIsMuted() ?? Array(repeating: false, count: 6)
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        return dateFormatter
    }()
    
    private init() {}
    
    func getNotificationAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
          let center = UNUserNotificationCenter.current()
          center.getNotificationSettings { settings in
              completion(settings.authorizationStatus)
          }
      }
    
    func openAppSettings() {
           if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url, options: [:], completionHandler: nil)
           }
       }

    
    func scheduleNotification(at date: Date, body: String, identifier: String, language: String) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                let content = UNMutableNotificationContent()
                if language == "ru"{
                    content.title = "Ассаламу Алейкум!"
                }
                else if language == "kz"{
                    content.title = "Ассалаумағалейкум!"
                }
                else if language == "ar"{
                    content.title = "السلام عليكم!"
                }else{
                    content.title = "Assalamu Alaikum!"
                }
                
                content.body = body
                content.sound = UNNotificationSound.default
                
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    } else {
                        print("Notification scheduled: \(identifier)")
                    }
                }
            } else {
                print("Permission not granted for notifications.")
            }
        }
    }
    
    func reschedule(language: String) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All scheduled notifications have been unscheduled.")
        
        for (index, time) in prayerTimes.enumerated() {
            if language == "ru"{
                if let date = dateFormatter.date(from: "\(time.date) \(time.fajrTime)"), !isMutedArray[0] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "Фаджр молитва в городе \(time.cityName)", identifier: "\(time.date)_fajr", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.sunriseTime)"), !isMutedArray[1] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "Восход в городе \(time.cityName)", identifier: "\(time.date)_sunrise", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.dhuhrTime)"), !isMutedArray[2] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "Зухр молитва в городе \(time.cityName)", identifier: "\(time.date)_dhuhr", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.asrTime)"), !isMutedArray[3] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "Аср молитва в городе \(time.cityName)", identifier: "\(time.date)_asr", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.maghribTime)"), !isMutedArray[4] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "Магриб молитва в городе \(time.cityName)", identifier: "\(time.date)_maghrib", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.ishaTime)"), !isMutedArray[5] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "Иша молитва в городе \(time.cityName)", identifier: "\(time.date)_isha", language: language)
                }
            }
            else if language == "kk"{
                if let date = dateFormatter.date(from: "\(time.date) \(time.fajrTime)"), !isMutedArray[0] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "\(time.cityName) қаласында таң намазы", identifier: "\(time.date)_fajr", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.sunriseTime)"), !isMutedArray[1] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "\(time.cityName) қаласында күн шықты", identifier: "\(time.date)_sunrise", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.dhuhrTime)"), !isMutedArray[2] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "\(time.cityName) қаласында бесін намазы", identifier: "\(time.date)_dhuhr", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.asrTime)"), !isMutedArray[3] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "\(time.cityName) қаласында екінті намазы", identifier: "\(time.date)_asr", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.maghribTime)"), !isMutedArray[4] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "\(time.cityName) қаласында ақшам намазы", identifier: "\(time.date)_maghrib", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.ishaTime)"), !isMutedArray[5] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "\(time.cityName) қаласында құптан намазы", identifier: "\(time.date)_isha", language: language)
                }
            }
            else if language == "ar"{
                if let date = dateFormatter.date(from: "\(time.date) \(time.fajrTime)"), !isMutedArray[0] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "صلاة الفجر في \(time.cityName)", identifier: "\(time.date)_fajr", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.sunriseTime)"), !isMutedArray[1] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "الشروق في \(time.cityName)", identifier: "\(time.date)_sunrise", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.dhuhrTime)"), !isMutedArray[2] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "صلاة الظهر في \(time.cityName)", identifier: "\(time.date)_dhuhr", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.asrTime)"), !isMutedArray[3] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "صلاة العصر في \(time.cityName)", identifier: "\(time.date)_asr", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.maghribTime)"), !isMutedArray[4] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "صلاة المغرب في \(time.cityName)", identifier: "\(time.date)_maghrib", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.ishaTime)"), !isMutedArray[5] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "صلاة العشاء في \(time.cityName)", identifier: "\(time.date)_isha", language: language)
                }
            }else{
                if let date = dateFormatter.date(from: "\(time.date) \(time.fajrTime)"), !isMutedArray[0] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "Fajr prayer in \(time.cityName)", identifier: "\(time.date)_fajr", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.sunriseTime)"), !isMutedArray[1] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "Sunrise in \(time.cityName)", identifier: "\(time.date)_sunrise", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.dhuhrTime)"), !isMutedArray[2] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "Dhuhr prayer in \(time.cityName)", identifier: "\(time.date)_dhuhr", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.asrTime)"), !isMutedArray[3] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "Asr prayer in \(time.cityName)", identifier: "\(time.date)_asr", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.maghribTime)"), !isMutedArray[4] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "Maghrib prayer in \(time.cityName)", identifier: "\(time.date)_maghrib", language: language)
                }
                
                if let date = dateFormatter.date(from: "\(time.date) \(time.ishaTime)"), !isMutedArray[5] {
                    NotificationManager.shared.scheduleNotification(at: date, body: "Isha prayer in \(time.cityName)", identifier: "\(time.date)_isha", language: language)
                }
            }
                    
        }
    }
    
//    func scheduleNotificationIfNeeded(prayerTime: String, isMuted: Bool, prayerTimes: [String: String]) {
//        // Check if the notification is enabled (not muted)
//        guard !isMuted else {
//            // If muted, cancel any previously scheduled notifications for this prayer time
//            cancelNotification(for: prayerTime)
//            return
//        }
//
//        // Get the date components for the prayer time using the prayerTimes parameter
//        let prayerTimeComponents = prayerTimes[prayerTime]?.split(separator: ":")
//            .compactMap { Int($0) }
//            .suffix(2)
//
//        guard let hour = prayerTimeComponents?.first, let minute = prayerTimeComponents?.last else {
//            return
//        }
//
//        var dateComponents = DateComponents()
//        dateComponents.hour = hour
//        dateComponents.minute = minute
//
//        let content = UNMutableNotificationContent()
//        content.title = "It's time to pray"
//        content.body = prayerTime
//        content.sound = .default
//
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//        let request = UNNotificationRequest(identifier: prayerTime, content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("Error scheduling notification for \(prayerTime): \(error.localizedDescription)")
//            } else {
//                let formattedHour = String(format: "%02d", dateComponents.hour ?? 0)
//                let formattedMinute = String(format: "%02d", dateComponents.minute ?? 0)
//                print("Notification scheduled for \(prayerTime) at \(formattedHour):\(formattedMinute)")
//            }
//        }
//    }
    
    
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
