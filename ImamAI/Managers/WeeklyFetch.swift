import Foundation
import CoreData

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

func makeRequestAndUpdateCoreData() {
    print("core data function called")
    let locationManager = LocationManager.shared

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
    
    let oneWeekInSeconds: TimeInterval = 7 * 24 * 60 * 60
    let timer = Timer.scheduledTimer(withTimeInterval: oneWeekInSeconds, repeats: true) { _ in
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
                let prayerTimes = try decoder.decode([PrayerTime].self, from: data)
                print("Prayer times: \(prayerTimes)")
                
                let context = PersistenceManager.shared.persistentContainer.viewContext

                for prayerTime in prayerTimes {
                    let fetchRequest: NSFetchRequest<PrayingTime> = PrayingTime.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "cityName = %@", prayerTime.cityName ?? "")
                    do {
                        let existingPrayingTimes = try context.fetch(fetchRequest)
                        if let existingPrayingTime = existingPrayingTimes.first {
                            existingPrayingTime.fajrTime = prayerTime.fajrTime
                            existingPrayingTime.sunriseTime = prayerTime.sunriseTime
                            existingPrayingTime.dhuhrTime = prayerTime.dhuhrTime
                            existingPrayingTime.asrTime = prayerTime.asrTime
                            existingPrayingTime.maghribTime = prayerTime.maghribTime
                            existingPrayingTime.ishaTime = prayerTime.ishaTime
                        } else {
                            let newPrayingTime = PrayingTime(context: context)
                            newPrayingTime.cityName = prayerTime.cityName
                            newPrayingTime.fajrTime = prayerTime.fajrTime
                            newPrayingTime.sunriseTime = prayerTime.sunriseTime
                            newPrayingTime.dhuhrTime = prayerTime.dhuhrTime
                            newPrayingTime.asrTime = prayerTime.asrTime
                            newPrayingTime.maghribTime = prayerTime.maghribTime
                            newPrayingTime.ishaTime = prayerTime.ishaTime
                        }
                        
                        try context.save()
                    } catch {
                        print("Error fetching or creating PrayingTime: \(error)")
                    }
                }
            } catch {
                print("Error decoding prayer times data: \(error)")
            }
        }
        task.resume()
    }

    timer.fire()
}
