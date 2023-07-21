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
    @StateObject var locationManager = LocationManager()
    @StateObject var scrollStore = ScrollPositionStore()
    @State private var selectedTab: Tab = .loading
    @State private var isLoadingComplete = false
    @State private var city: String = ""
    @State private var isLocationUpdating = true
    
    var initialTab: Tab {
        if locationManager.location != nil {
            return .home
        } else {
            return .loading
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                switch selectedTab {
                case .home:
                    if !prayerTimes.isEmpty {
                        HomeView(selectedTab: $selectedTab, prayerTimes: prayerTimes, city: city)
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
            
            if isLoadingComplete {
                TabBarView(selectedTab: $selectedTab)
            }
            
            if selectedTab == .loading || isLocationUpdating {
                // Show the loading view when location updates are in progress
                LoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            if selectedTab == .loading {
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
            if let _ = newLocation, selectedTab == .loading {
                // Introduce a delay of 2 seconds before fetching prayer times
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    makeRequest()
                }
            }
        }
        
        .onAppear {
            // Introduce a delay of 2 seconds before fetching prayer times
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                fetchPrayerTimesFromCoreData()
            }
        }
    }
    
    @State private var prayerTimes: [String: String] = [:]
    
    func fetchPrayerTimesFromCoreData() {
        let fetchRequest: NSFetchRequest<PrayingTime> = PrayingTime.fetchRequest()
        fetchRequest.predicate = NSPredicate(value: true) // Fetch all records
        
        do {
            let prayerTimesData = try PersistenceManager.shared.persistentContainer.viewContext.fetch(fetchRequest)
            if let latestPrayingTime = prayerTimesData.last {
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
                self.selectedTab = .home
                self.isLoadingComplete = true
                self.city = latestPrayingTime.cityName ?? "Алматы"
            } else {
                // No data available in CoreData, make an API request
                makeRequestAndUpdateCoreData()
            }
        } catch {
            print("Error fetching prayer times data from CoreData: \(error)")
        }
    }
    
    
    
    
    
    
    
    
    func makeRequest() {
        print("making time request")
        
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
        
        URLSession.shared.dataTask(with: request) { data, response, error in
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
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let prayerTimesData = try decoder.decode(PrayerTimesData.self, from: data)
                DispatchQueue.main.async {
                    // Here, directly use the properties of prayerTimesData
                    self.prayerTimes = [
                        "Фаджр": prayerTimesData.fajrTime,
                        "Восход": prayerTimesData.sunriseTime,
                        "Зухр": prayerTimesData.dhuhrTime,
                        "Аср": prayerTimesData.asrTime,
                        "Магриб": prayerTimesData.maghribTime,
                        "Иша": prayerTimesData.ishaTime
                    ]
                    self.selectedTab = .home
                    self.isLoadingComplete = true
                    self.city = prayerTimesData.cityName
                    self.isLocationUpdating = false
                }
                print("decoded")
                print(prayerTimesData)
            } catch {
                print("Error decoding prayer times data: \(error)")
                DispatchQueue.main.async {
                    self.isLocationUpdating = false
                }
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
