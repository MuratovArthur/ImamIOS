//
//  WeeklyFetch.swift
//  ImamAI
//
//  Created by Muratov Arthur on 21.07.2023.
//

import Foundation
import CoreData // Add this import statement to access PrayingTime entity

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

struct PrayerTimesData: Codable {
    let cityName: String
    let fajrTime: String
    let sunriseTime: String
    let dhuhrTime: String
    let asrTime: String
    let maghribTime: String
    let ishaTime: String
}



func makeRequestAndUpdateCoreData() {
    
    let locationManager = LocationManager()
    
    // Create the API request
    guard let location = locationManager.location else {
        print("No location available")
        return
    }
    
    let latitude = String(location.coordinate.latitude)
    let longitude = String(location.coordinate.longitude)
    
    let url = URL(string: "https://fastapi-s53t.onrender.com/imam/get_time")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let parameters: [String: Any] = ["lat": latitude, "lon": longitude]
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
    } catch {
        print("Error encoding parameters: \(error)")
        return
    }
    
    // Create a weekly repeating timer for making the API request
        let oneWeekInSeconds: TimeInterval = 7 * 24 * 60 * 60
        let timer = Timer.scheduledTimer(withTimeInterval: oneWeekInSeconds, repeats: true) { _ in
            // Make the API request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error making API request: \(error)")
                    return
                }
                
                guard let data = data else {
                    print("Empty response data")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.userInfo[.managedObjectContext] = PersistenceManager.shared.persistentContainer.viewContext
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let prayerTimesData = try decoder.decode(PrayerTimesData.self, from: data)
                    
                    // Update CoreData with the received data
                    let context = PersistenceManager.shared.persistentContainer.viewContext
                    
                    // Fetch the existing record, if any
                    let fetchRequest: NSFetchRequest<PrayingTime> = PrayingTime.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "cityName = %@", prayerTimesData.cityName)
                    do {
                        let existingPrayingTimes = try context.fetch(fetchRequest)
                        if let existingPrayingTime = existingPrayingTimes.first {
                            // Update existing record
                            existingPrayingTime.fajrTime = prayerTimesData.fajrTime
                            existingPrayingTime.sunriseTime = prayerTimesData.sunriseTime
                            existingPrayingTime.dhuhrTime = prayerTimesData.dhuhrTime
                            existingPrayingTime.asrTime = prayerTimesData.asrTime
                            existingPrayingTime.maghribTime = prayerTimesData.maghribTime
                            existingPrayingTime.ishaTime = prayerTimesData.ishaTime
                        } else {
                            // Create a new record
                            let newPrayingTime = PrayingTime(context: context)
                            newPrayingTime.cityName = prayerTimesData.cityName
                            newPrayingTime.fajrTime = prayerTimesData.fajrTime
                            newPrayingTime.sunriseTime = prayerTimesData.sunriseTime
                            newPrayingTime.dhuhrTime = prayerTimesData.dhuhrTime
                            newPrayingTime.asrTime = prayerTimesData.asrTime
                            newPrayingTime.maghribTime = prayerTimesData.maghribTime
                            newPrayingTime.ishaTime = prayerTimesData.ishaTime
                        }
                        
                        // Save changes to CoreData
                        try context.save()
                        print("Data updated successfully")
                    } catch {
                        print("Error fetching or creating PrayingTime: \(error)")
                    }
                } catch {
                    print("Error decoding prayer times data: \(error)")
                }
            }
            task.resume()
        }

        // Start the timer
        timer.fire()
    }
