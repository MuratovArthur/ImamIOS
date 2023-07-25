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
    @State private var tabBarShouldBeHidden = false
    @State private var useAlmatyLocation = false
    @StateObject var networkMonitor = NetworkMonitor()
    @State var errorText: String = ""
    @State var firstTimeInApp = true
    
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
                    HomeView(selectedTab: $selectedTab, prayerTime: $prayerTime, city: $city, tabBarShouldBeHidden: $tabBarShouldBeHidden, useAlmatyLocation: $useAlmatyLocation, firstTimeInApp:$firstTimeInApp)
                        .environmentObject(scrollStore)
                        .navigationBarHidden(true)
                case .other:
                    ChatScreen(viewModel: ChatViewModel(), selectedTab: $selectedTab)
                        .navigationBarHidden(true)
                case .settings:
                    CompassView()
                        .navigationBarHidden(true)
                case .loading:
                    LoadingView(errorText: $errorText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .environmentObject(networkMonitor)
                }
                
                
                Spacer()
            }
            .edgesIgnoringSafeArea(.bottom)
            .padding(.bottom, calculateBottomPadding())
            
            if selectedTab != .loading, tabBarShouldBeHidden==false {
                TabBarView(selectedTab: $selectedTab)
            }
        }
        .onChange(of: locationManager.authorizationStatus) { status in
            switch status {
            case .denied, .restricted:
                useAlmatyLocation = true
                makeRequestWithRetry(attempts: 5)
            default:
                break
            }
        }
        .onChange(of: locationManager.location) { newLocation in
            if !isPrayerTimeReceived && !isRequestInProgress {
                makeRequestWithRetry(attempts: 5)
            }
        }
        
        .onAppear {
            requestNotificationAuthorization()
        }
        .onChange(of: networkMonitor.isConnected) { isConnected in
            print("Status changed")
            if isConnected {
                makeRequestWithRetry(attempts: 5)
            }
        }
    }
    
    private func calculateBottomPadding() -> CGFloat {
        // Define your conditions here and return the appropriate padding amount
        if selectedTab != .loading && !tabBarShouldBeHidden {
            return 50
        } else {
            return 0
        }
    }
    
    func requestNotificationAuthorization() {
           UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
               if success {
                   print("Notification authorization successful!")
               }

               // Call the function to request location authorization regardless of the notification result
               self.requestLocationAuthorization()
           }
       }
    
    func requestLocationAuthorization() {
        self.locationManager.requestWhenInUseAuthorization() // Request location access permission
    }
    
    func makeRequest() {
        print("making request")
        
        var latitude = ""
        var longitude = ""
        
        if !useAlmatyLocation{
            guard let location = locationManager.location else {
                errorText = "Произошла ошибка. Проверьте интернет соединение и попробуйте перезайти."
                return
            }
            latitude = String(location.coordinate.latitude)
            longitude = String(location.coordinate.longitude)
        }else{
            latitude = "43.238293"
            longitude = "76.945465"
        }
        
        guard !isPrayerTimeReceived && !isRequestInProgress else {
            print("Prayer times already received or request already in progress.")
            return
        }
        
        isRequestInProgress = true
        
        
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
            errorText = "Произошла ошибка. Проверьте интернет соединение и попробуйте перезайти."
            isRequestInProgress = false
            return
        }
        
        // Retry mechanism variables
        let maxRetryAttempts = 3
        var currentRetryAttempt = 0
        
        func sendRequest() {
            currentRetryAttempt += 1
            
            // Start the network request to fetch prayer times
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                defer { self.isRequestInProgress = false }
                
                if let error = error {
                    if currentRetryAttempt < maxRetryAttempts {
                        errorText = "Произошла ошибка. Проверьте интернет соединение и попробуйте перезайти."
                        print(error)
                        sendRequest() // Retry the request
                    } else {
                        errorText = "Произошла ошибка. Проверьте интернет соединение и попробуйте перезайти."
                    }
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    errorText = "Произошла ошибка. Проверьте интернет соединение и попробуйте перезайти."
                    return
                }
                
                guard let data = data else {
                    errorText = "Произошла ошибка. Проверьте интернет соединение и попробуйте перезайти."
                    return
                }
                
                do {
                    let array = try JSONDecoder().decode([PrayerTime].self, from: data)
                    
                    guard let todayPrayerTime = array.first else {
                        errorText = "Произошла ошибка. Проверьте интернет соединение и попробуйте перезайти."
                        return
                    }
                    
                    self.prayerTime = todayPrayerTime
                    self.city = todayPrayerTime.cityName
                    self.selectedTab = .home
                    self.isPrayerTimeReceived = true
                    
                    NotificationManager.shared.prayerTimes = array
                    NotificationManager.shared.reschedule()
                    
                } catch {
                    errorText = "Произошла ошибка. Проверьте интернет соединение и попробуйте перезайти."
                }
            }
            
            task.resume()
        }
        
        sendRequest()
    }
    
    func makeRequestWithRetry(attempts: Int) {
        guard !isRequestInProgress else { return }
        
        DispatchQueue.main.async {
            if !self.isPrayerTimeReceived {
                self.makeRequest()
                
                // if we didn't get prayer times, we will retry after 2 seconds
                if !self.isPrayerTimeReceived && attempts > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.makeRequestWithRetry(attempts: attempts - 1)
                    }
                } else if attempts == 0 {
                    errorText = "Произошла ошибка. Проверьте интернет соединение и попробуйте перезайти."
                }
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
