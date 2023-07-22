import SwiftUI
import CoreData

struct ContentView: View {
    enum Tab {
        case loading
        case home
        case other
        case settings
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var locationManager = LocationManager.shared
    @StateObject var scrollStore = ScrollPositionStore()
    @State private var selectedTab: Tab = .loading
    @State private var isLoadingComplete = false
    @State private var city: String = ""
    @State private var isLocationUpdating = true
    @State private var isPrayerTimeReceived = false
    
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
                    makeRequest()
                }
            }
        }
        .onAppear {
            //            makeRequestWithRetry(attempts: 5)
            fetchPrayerTimesFromCoreData()
        }
    }
    
    func fetchPrayerTimesFromCoreData() {
        print("calling fetchPrayerTimesFromCoreData")
        
    

        let fetchRequest: NSFetchRequest<PrayingTime> = PrayingTime.fetchRequest()
        fetchRequest.predicate = NSPredicate(value: true) // Fetch all records
        
        do {
            let prayerTimesData = try viewContext.fetch(fetchRequest)
            if !prayerTimesData.isEmpty {
                // Data exists in CoreData, use the latest data
                let latestPrayingTime = prayerTimesData.last!
                var prayerTimesDict: [String: String] = [:]
                
                if let fajrTime = latestPrayingTime.fajrTime {
                    prayerTimesDict["Фаджр"] = fajrTime
                }
                if let sunriseTime = latestPrayingTime.sunriseTime {
                    prayerTimesDict["Восход"] = sunriseTime
                }
                if let dhuhrTime = latestPrayingTime.dhuhrTime {
                    prayerTimesDict["Зухр"] = dhuhrTime
                }
                if let asrTime = latestPrayingTime.asrTime {
                    prayerTimesDict["Аср"] = asrTime
                }
                if let maghribTime = latestPrayingTime.maghribTime {
                    prayerTimesDict["Магриб"] = maghribTime
                }
                if let ishaTime = latestPrayingTime.ishaTime {
                    prayerTimesDict["Иша"] = ishaTime
                }
                
                self.prayerTimes = prayerTimesDict
                self.isLoadingComplete = true
                if isPrayerTimeReceived {
                    self.selectedTab = .home
                }
                self.city = latestPrayingTime.cityName ?? "Алматы"
                
            } else {
                makeRequestAndUpdateCoreData()
            }
        } catch {
            print("Error fetching prayer times data from CoreData: \(error)")
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
        
        // Start the network request to fetch prayer times
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                let decoder = JSONDecoder()
                
                do {
                    // Decode the JSON response into an array of dictionaries
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]] {
                        print("Received JSON Array: \(jsonArray)")
                        
                        // Assuming the JSON response is an array of dictionaries, parse the first element in the array
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
                            }
                        } else {
                            print("Empty array of prayer times data")
                        }
                    } else {
                        print("Failed to decode JSON data: Unexpected format")
                    }
                } catch {
                    print("Failed to decode JSON data: \(error)")
                }
            }
        }
        
        task.resume()
    }
    
    func makeRequestWithRetry(attempts: Int) {
        guard attempts > 0 else {
            print("Failed to get location after multiple attempts.")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            guard let _ = self.locationManager.location else {
                print("No location available. Retrying...")
                self.makeRequestWithRetry(attempts: attempts - 1)
                return
            }
            
            makeRequestAndUpdateCoreData()
        }
    }
    
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


extension Notification.Name {
    static let prayerTimesUpdated = Notification.Name("prayerTimesUpdated")
}
