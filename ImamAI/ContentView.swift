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
    @State private var city: String = ""
    @State private var isLocationUpdating = true
    @State private var isPrayerTimeReceived = false
    @State private var isRequestInProgress = false
    
    @State private var prayerTimes: [String: String] = [
        "Фаджр": "",
        "Восход": "",
        "Зухр": "",
        "Аср": "",
        "Магриб": "",
        "Иша": ""
    ]
    
    @State private var prayerTime: PrayerTime?
    
    // Define the jsonArray variable here
    var jsonArray: [[String: Any]] = []
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                switch selectedTab {
                case .home:
                    HomeView(selectedTab: $selectedTab, prayerTime: $prayerTime, city: $city)
                        .environmentObject(scrollStore)
                        .navigationBarHidden(true)
                case .other:
                    ChatScreen(viewModel: ChatViewModel(), selectedTab: $selectedTab)
                        .navigationBarHidden(true)
                case .settings:
                    CompassView()
                        .navigationBarHidden(true)
                case .loading:
                    LoadingView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                Spacer()
            }
            .padding(.bottom, selectedTab != .loading ? 50 : 0)
            
            if selectedTab != .loading {
                TabBarView(selectedTab: $selectedTab)
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
            if !isPrayerTimeReceived {
                makeRequestWithRetry(attempts: 5)
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
        }
    }
    
    func makeRequest() {
        print("making request")
        
        guard let location = locationManager.location else {
            print("No location available. Waiting for location update.")
            return
        }
        
        guard !isPrayerTimeReceived else {
            print("Prayer times already received.")
            self.isPrayerTimeReceived = true
            return
        }
        
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        
        // Get current date and format it
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let formattedDate = dateFormatter.string(from: currentDate)
        
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
                do {
                    let array = try JSONDecoder().decode([PrayerTime].self, from: data)
        
                    if let todayPrayerTime = array.first {
                        self.prayerTime = todayPrayerTime
                        self.city = todayPrayerTime.cityName
                        self.selectedTab = .home
                        self.isPrayerTimeReceived = true
                    }
                    
                    NotificationManager.shared.prayerTimes = array
                    NotificationManager.shared.reschedule()
                    
                    isPrayerTimeReceived = true
                    isRequestInProgress = false
                }
                catch {
                    print("An error occurred while trying to deserialize the JSON data: \(error)")
                }

            }
        }
        
        task.resume()
    }
    
    func makeRequestWithRetry(attempts: Int) {
        guard !isRequestInProgress else { return }
        
        DispatchQueue.main.async {
            if !self.isPrayerTimeReceived {
                self.isRequestInProgress = true
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
