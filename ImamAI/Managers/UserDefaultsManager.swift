//
//  UserDefaultsManager.swift
//  ImamAI
//
//  Created by Muratov Arthur on 20.07.2023.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let isMutedKey = "isMutedKey"
    private let conversationIDKey = "conversationIDKey"
    private let appLanguage = "appLanguage"
    private let settingsAlertShown = "settingsAlertShown"
    private let countryKey = "country"
    private let cityKey = "city"

    func getCountry() -> String? {
        return UserDefaults.standard.string(forKey: countryKey)
    }

    func setCountry(_ country: String) {
        UserDefaults.standard.set(country, forKey: countryKey)
    }

    func getCity() -> String? {
        return UserDefaults.standard.string(forKey: cityKey)
    }

    func setCity(_ city: String) {
        UserDefaults.standard.set(city, forKey: cityKey)
    }
    
    func setSettingsAlertShown(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: settingsAlertShown)
    }
    
    func getSettingsAlertShown() -> Bool {
        return UserDefaults.standard.bool(forKey: settingsAlertShown)
    }
    
    func setLanguage(_ value: String) {
        UserDefaults.standard.set(value, forKey: appLanguage)
    }
    
    func getLanguage() -> String? {
        return UserDefaults.standard.string(forKey: appLanguage)
    }
    
    func saveIsMuted(_ value: [Bool]) {
        UserDefaults.standard.set(value, forKey: isMutedKey)
    }
    
    func getIsMuted() -> [Bool]? {
        return UserDefaults.standard.array(forKey: isMutedKey) as? [Bool]
    }
    
    func saveConversationID(_ id: String) {
        UserDefaults.standard.set(id, forKey: conversationIDKey)
    }
    
    func getConversationID() -> String? {
        return UserDefaults.standard.string(forKey: conversationIDKey)
    }
    
    // Optional: If you want to update the muted status for a specific prayer time
    func updateMutedStatus(for prayerTime: String, isMuted: Bool) {
        var mutedStatus = getIsMuted() ?? Array(repeating: false, count: 6)
        guard let index = ["Фаджр","Восход", "Зухр", "Аср", "Магриб", "Иша"].firstIndex(of: prayerTime) else {
            return
        }
        mutedStatus[index] = isMuted
        saveIsMuted(mutedStatus)
    }
}


