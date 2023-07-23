//
//  PrayerTime.swift
//  ImamAI
//
//  Created by Muratov Arthur on 22.07.2023.
//

import Foundation

struct PrayerTime: Codable {
    let date: String
    let cityName: String
    let asrTime: String
    let ishaTime: String
    let sunriseTime: String
    let maghribTime: String
    let dhuhrTime: String
    let fajrTime: String

    enum CodingKeys: String, CodingKey {
        case date
        case cityName = "city_name"
        case asrTime = "asr_time"
        case ishaTime = "isha_time"
        case sunriseTime = "sunrise_time"
        case maghribTime = "maghrib_time"
        case dhuhrTime = "dhuhr_time"
        case fajrTime = "fajr_time"
    }
    
    var orderedValues: [String: String?] {
        [
            "Фаджр": fajrTime,
            "Восход": sunriseTime,
            "Зухр": dhuhrTime,
            "Аср": asrTime,
            "Магриб": maghribTime,
            "Иша": ishaTime
        ]
    }
}

