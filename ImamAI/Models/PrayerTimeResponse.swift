//
//  PrayerTimeResponse.swift
//  ImamAI
//
//  Created by Nurali Rakhay on 16.08.2023.
//

import Foundation

struct PrayerTimeResponse: Codable {
    let data: [SingleDayPrayerTime]
}

struct SingleDayPrayerTime: Codable {
    let timings: [Prayers]
}

struct Prayers: Codable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}
