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
    
    func saveIsMuted(_ value: [Bool]) {
        UserDefaults.standard.set(value, forKey: isMutedKey)
    }
    
    func getIsMuted() -> [Bool]? {
        return UserDefaults.standard.array(forKey: isMutedKey) as? [Bool]
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

