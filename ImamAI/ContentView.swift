import SwiftUI

struct ContentView: View {
    enum Tab {
        case loading
        case home
        case other
        case settings
    }
    
    @StateObject var locationManager = LocationManager.shared
    @StateObject var scrollStore = ScrollPositionStore()
    @State private var selectedTab: Tab = .loading
    @State private var isLoadingComplete = false
    @State private var city: String = ""
    @State private var isLocationUpdating = true
    @State private var isPrayerTimeReceived = false
    @State private var arePrayerTimesFetched = false
    
    @State private var prayerTimes: [String: String] = [
        "Фаджр": "",
        "Восход": "",
        "Зухр": "",
        "Аср": "",
        "Магриб": "",
        "Иша": ""
    ]
    
    // Define the jsonArray variable here
    var jsonArray: [[String: Any]] = []
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                switch selectedTab {
                case .home:
                    if !locationManager.shouldContinueUpdatingLocation {
                        HomeView(selectedTab: $selectedTab, prayerTimes: $prayerTimes, city: $city)
                            .environmentObject(scrollStore)
                            .navigationBarHidden(true)
                    } else {
                        ProgressView()
                    }
                case .other:
                    ChatScreen(viewModel: ChatViewModel(), selectedTab: $selectedTab)
                        .navigationBarHidden(true)
                case .settings:
                    CompassView()
                        .navigationBarHidden(true)
                default:
                    EmptyView()
                }
                Spacer()
            }
            .padding(.bottom, isLoadingComplete ? 50 : 0)
            
            if isLoadingComplete && selectedTab != .loading {
                TabBarView(selectedTab: $selectedTab)
            }
            
            if locationManager.shouldContinueUpdatingLocation || selectedTab == .loading {
                LoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onChange(of: locationManager.authorizationStatus) { status in
            switch status {
            case .denied, .restricted:
                print("Location permission denied or restricted.")
                // Handle location permission denied or restricted cases here
            default:
                break
            }
        }
        .onChange(of: locationManager.location) { newLocation in
            if let _ = newLocation, locationManager.shouldContinueUpdatingLocation, !isPrayerTimeReceived {
                locationManager.shouldContinueUpdatingLocation = false // prevent further updates
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    makeRequestWithRetry(attempts: 5)
                }
            }
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            makeRequestWithRetry(attempts: 5)
        }
    }
    
    func makeRequest() {
        guard let location = locationManager.location else {
            print("No location available. Waiting for location update.")
            return
        }
        
        guard !isPrayerTimeReceived else {
            print("Prayer times already received.")
            return
        }
        
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        
        // Get current date and format it
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let formattedDate = dateFormatter.string(from: currentDate)
        print("CUrrent date: ", formattedDate)
        
        let url = URL(string: "https://fastapi-s53t.onrender.com/imam/get_time")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = ["lat": latitude, "lon": longitude, "date": formattedDate]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("Error encoding parameters: \(error)")
            return
        }
        
        
        // Start the network request to fetch prayer times
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                print("Response Received", response)
                let decoder = JSONDecoder()
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                do {
                    unscheduleAllNotifications()
//                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]] {
                        if var jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]] {
                        print("Received JSON Array: \(jsonArray)")

                                                                
                        if let prayerTimesData = jsonArray.first {
                            DispatchQueue.main.async {
                                self.prayerTimes["Фаджр"] = prayerTimesData["fajr_time"]
                                self.prayerTimes["Восход"] = prayerTimesData["sunrise_time"]
                                self.prayerTimes["Зухр"] = prayerTimesData["dhuhr_time"]
                                self.prayerTimes["Аср"] = prayerTimesData["asr_time"]
                                self.prayerTimes["Магриб"] = prayerTimesData["maghrib_time"]
                                self.prayerTimes["Иша"] = prayerTimesData["isha_time"]
                                self.city = prayerTimesData["city_name"] ?? "Алматы"
                                
                                self.isPrayerTimeReceived = true
                                self.isLoadingComplete = true
                                self.selectedTab = .home
                                self.arePrayerTimesFetched = true
                            }
                        } else {
                            print("Empty array of prayer times data")
                        }
                        
                        for prayerTimes in jsonArray {
                            if let dateString = prayerTimes["date"],
                                let fajrTimeString = prayerTimes["fajr_time"],
                                let sunriseTimeString = prayerTimes["sunrise_time"],
                                let dhuhrTimeString = prayerTimes["dhuhr_time"],
                                let asrTimeString = prayerTimes["asr_time"],
                                let maghribTimeString = prayerTimes["maghrib_time"],
                                let ishaTimeString = prayerTimes["isha_time"],
                                let city = prayerTimes["city_name"] {

                                if let date = dateFormatter.date(from: "\(dateString) \(fajrTimeString)") {
                                    scheduleNotification(at: date, body: "Фаджр молитва в \(city)", identifier: "\(dateString)_fajr")
                                } else {
                                    print("Could not convert '\(dateString) \(fajrTimeString)' to a Date.")
                                }

                                if let date = dateFormatter.date(from: "\(dateString) \(sunriseTimeString)") {
                                    scheduleNotification(at: date, body: "Восход в \(city)", identifier: "\(dateString)_sunrise")
                                } else {
                                    print("Could not convert '\(dateString) \(sunriseTimeString)' to a Date.")
                                }

                                if let date = dateFormatter.date(from: "\(dateString) \(dhuhrTimeString)") {
                                    scheduleNotification(at: date, body: "Зухр молитва в \(city)", identifier: "\(dateString)_dhuhr")
                                } else {
                                    print("Could not convert '\(dateString) \(dhuhrTimeString)' to a Date.")
                                }

                                if let date = dateFormatter.date(from: "\(dateString) \(asrTimeString)") {
                                    scheduleNotification(at: date, body: "Аср молитва в \(city)", identifier: "\(dateString)_asr")
                                } else {
                                    print("Could not convert '\(dateString) \(asrTimeString)' to a Date.")
                                }

                                if let date = dateFormatter.date(from: "\(dateString) \(maghribTimeString)") {
                                    scheduleNotification(at: date, body: "Магриб молитва в \(city)", identifier: "\(dateString)_maghrib")
                                } else {
                                    print("Could not convert '\(dateString) \(maghribTimeString)' to a Date.")
                                }

                                if let date = dateFormatter.date(from: "\(dateString) \(ishaTimeString)") {
                                    scheduleNotification(at: date, body: "Иша молита \(city)", identifier: "\(dateString)_isha")
                                } else {
                                    print("Could not convert '\(dateString) \(ishaTimeString)' to a Date.")
                                }
                                
                                arePrayerTimesFetched = true
                            } else {
                                print("Unable to unwrap all required values.")
                            }
                        }

                    }
                    else {
                        print("Failed to decode JSON data: Unexpected format")
                    }
                }
                catch {
                    print("An error occurred while trying to deserialize the JSON data: \(error)")
                }

            }
        }
        
        task.resume()
    }
    func unscheduleAllNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        print("All scheduled notifications have been unscheduled.")
    }
    
    func schedulePrayerNotifications(with prayerTimes: [String: [Date]]) {
        print("Scheduling notifications")
        let notificationCenter = UNUserNotificationCenter.current()
        let prayerNames = ["Фаджр", "Восход", "Зухр", "Аср", "Магриб", "Иша"]
        let isMutedArray = UserDefaultsManager.shared.getIsMuted() ?? Array(repeating: false, count: 6)
        
        // Unschedule all existing notifications
        notificationCenter.removeAllPendingNotificationRequests()
        
        for (index, prayer) in prayerNames.enumerated() {
            
            //            print(prayerTimes[prayer], !isMutedArray[index])
            
            guard let times = prayerTimes[prayer], !isMutedArray[index] else {
                continue
            }
            
            for time in times {
                let content = UNMutableNotificationContent()
                content.title = "Prayer Time"
                content.body = "It's time for \(prayer)"
                
                let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,], from: time)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                notificationCenter.add(request) { (error) in
                    if let error = error {
                        print("Error scheduling notification for \(prayer): \(error)")
                    } else {
                        print("Successfully scheduled notification for \(prayer) at \(time)")
                    }
                }
            }
        }
    }
    
    func scheduleNotification(at date: Date, body: String, identifier: String) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                let content = UNMutableNotificationContent()
                content.title = "Prayer Time"
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
    
    func makeRequestWithRetry(attempts: Int) {
        DispatchQueue.main.async {
            if !self.arePrayerTimesFetched {
                self.arePrayerTimesFetched = true
                self.makeRequest()
            } else if attempts > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.makeRequestWithRetry(attempts: attempts - 1)
                }
            } else {
                print("Failed to get location after multiple attempts.")
            }
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
