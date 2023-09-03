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
                        print("Notification scheduled: \(identifier)", "Date: \(date)")
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Almaty")
        
        for (_, time) in prayerTimes.enumerated() {
            print("TIME: ", time)
            
            let prayers = [
                (time.fajrTime, "Fajr prayer in \(time.cityName)", "Фаджр молитва в городе \(time.cityName)", "\(time.cityName) қаласында таң намазы", "صلاة الفجر في \(time.cityName)", "\(time.date)_fajr"),
                (time.sunriseTime, "Sunrise in \(time.cityName)", "Восход в городе \(time.cityName)", "\(time.cityName) қаласында күн шықты", "الشروق في \(time.cityName)", "\(time.date)_sunrise"),
                (time.dhuhrTime, "Dhuhr prayer in \(time.cityName)", "Зухр молитва в городе \(time.cityName)", "\(time.cityName) қаласында бесін намазы", "صلاة الظهر في \(time.cityName)", "\(time.date)_dhuhr"),
                (time.asrTime, "Asr prayer in \(time.cityName)", "Аср молитва в городе \(time.cityName)", "\(time.cityName) қаласында екінті намазы", "صلاة العصر في \(time.cityName)", "\(time.date)_asr"),
                (time.maghribTime, "Maghrib prayer in \(time.cityName)", "Магриб молитва в городе \(time.cityName)", "\(time.cityName) қаласында ақшам намазы", "صلاة المغرب في \(time.cityName)", "\(time.date)_maghrib"),
                (time.ishaTime, "Isha prayer in \(time.cityName)", "Иша молитва в городе \(time.cityName)", "\(time.cityName) қаласында құптан намазы", "صلاة العشاء في \(time.cityName)", "\(time.date)_isha")
            ]
            
            for (index, prayer) in prayers.enumerated() {
                if !isMutedArray[index],
                   let date = dateFormatter.date(from: "\(time.date) \(prayer.0)") {
                    var body = prayer.1
                    if language == "ru" {
                        body = prayer.2
                    } else if language == "kk" {
                        body = prayer.3
                    } else if language == "ar" {
                        body = prayer.4
                    }
                    NotificationManager.shared.scheduleNotification(at: date, body: body, identifier: prayer.5, language: language)
                }
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
