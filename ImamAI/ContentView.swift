import SwiftUI
import Combine
import CoreLocation

struct ContentView: View {
    enum Tab {
        case loading
        case home
        case other
        case settings
    }
    
    enum APIError: Error {
        case invalidURL
        case httpError(Int)
        case noData
        case decodingError(Error)
        case other(Error)
    }
    
    @EnvironmentObject private var globalData: GlobalData
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
    
    @State private var translation: CGSize = .zero
    private let dragThreshold: CGFloat = 200
    
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
                    HomeView(selectedTab: $selectedTab, prayerTime: $prayerTime, city: $city, tabBarShouldBeHidden: $tabBarShouldBeHidden, useAlmatyLocation: $useAlmatyLocation)
                        .environmentObject(scrollStore)
                        .environmentObject(globalData)
                        .navigationBarHidden(true)
                case .other:
                    ChatScreen(viewModel: ChatViewModel(), selectedTab: $selectedTab)
                            .navigationBarHidden(true)
                            .contentShape(Rectangle())
                            .simultaneousGesture(DragGesture()
                                .onChanged { value in
                                    translation = value.translation
                                }
                                .onEnded { value in
                                    if translation.width > dragThreshold {
                                        selectedTab = .home
                                    }
                                    translation = .zero
                                }
                            )
                            .simultaneousGesture(TapGesture(count: 1)
                                .exclusively(before: DragGesture())
                            )
                            .environmentObject(globalData)
                case .settings:
                    CompassView()
                        .navigationBarHidden(true)
                        .environmentObject(globalData)
//                    FeaturesView()
                case .loading:
                    LoadingView(errorText: $errorText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .environmentObject(networkMonitor)
                        .environmentObject(globalData)
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
    
    func getCityAndCountry(latitude: Double, longitude: Double, completion: @escaping (String?, String?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }
            
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? ""
                let country = placemark.country ?? ""
                completion(city, country)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    func getDateComponents(from dateString: String) -> (Int, Int, Int)? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            
            if let date = dateFormatter.date(from: dateString) {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.day, .month, .year], from: date)
                
                if let day = components.day, let month = components.month, let year = components.year {
                    return (day, month, year)
                }
            }
            
            return nil
        }
    
    func makeRequest() {
        print("making request")
        
        var latitude = ""
        var longitude = ""
        
        if !useAlmatyLocation {
            guard let location = locationManager.location else {
                errorText = NSLocalizedString("no-internet-suggestion", bundle: globalData.bundle ?? Bundle.main, comment: "errors")
                return
            }
            latitude = String(location.coordinate.latitude)
            longitude = String(location.coordinate.longitude)
        } else {
            latitude = "43.238293"
            longitude = "76.945465"
        }
        
        guard !isPrayerTimeReceived && !isRequestInProgress else {
            print("Prayer times already received or request already in progress.")
            return
        }
        
//        let latFromDefaults = UserDefaultsManager.shared.getLocation().0
//        let lonFromDefaults = UserDefaultsManager.shared.getLocation().1
//
//        if !useAlmatyLocation {
//            if let latFromDefaults, let lonFromDefaults {
//                latitude = String(latFromDefaults)
//                longitude = String(lonFromDefaults)
//            } else {
//                guard let location = locationManager.location else {
//                    errorText = NSLocalizedString("no-internet-suggestion", bundle: globalData.bundle ?? Bundle.main, comment: "errors")
//                    return
//                }
//
//                latitude = String(location.coordinate.latitude)
//                longitude = String(location.coordinate.longitude)
//            }
//
//
//        } else {
//            if let latFromDefaults, let lonFromDefaults {
//                latitude = String(latFromDefaults)
//                longitude = String(lonFromDefaults)
//            } else {
//                latitude = "43.238293"
//                longitude = "76.945465"
//
//                UserDefaultsManager.shared.setLocation(lat: 43.238293, lon: 76.945465)
//                UserDefaultsManager.shared.setCity("Almaty")
//                UserDefaultsManager.shared.setCountry("Kazakhstan")
//            }
//        }
        
//        print(latitude, longitude)
        
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
        
        let (day, month, year) = getDateComponents(from: formattedDate)!
        
        // Retry mechanism variables
        let maxRetryAttempts = 3
        var currentRetryAttempt = 0
        
        func sendRequest(completion: @escaping (Result<PrayerTimeResponse, APIError>) -> Void) {
            currentRetryAttempt += 1
            
            func performRequest() {
                let urlString = "http://api.aladhan.com/v1/calendar/\(year)/\(month)?latitude=\(latitude)&longitude=\(longitude)&method=2"
                print(urlString)
                    
                guard let url = URL(string: urlString) else {
                    completion(.failure(.invalidURL))
                    return
                }
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    defer { self.isRequestInProgress = false }
                    
                    if let error = error {
                        if currentRetryAttempt < maxRetryAttempts {
                            currentRetryAttempt += 1
                            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                                performRequest()
                            }
                        } else {
                            completion(.failure(.other(error)))
                            
                        }
                        
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        completion(.failure(.httpError(0)))
                        return
                    }
                    
                    if !(200...299).contains(httpResponse.statusCode) {
                        if currentRetryAttempt < maxRetryAttempts {
                            currentRetryAttempt += 1
                            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                                performRequest()
                            }
                        } else {
                            completion(.failure(.httpError(httpResponse.statusCode)))
                        }
                        return
                    }
                    
                    guard let data = data else {
                        if currentRetryAttempt < maxRetryAttempts {
                            currentRetryAttempt += 1
                            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                                performRequest()
                            }
                        } else {
                            completion(.failure(.noData))
                        }
                        return
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(PrayerTimeResponse.self, from: data)
                        completion(.success(response))
                    } catch {
                        if currentRetryAttempt < maxRetryAttempts {
                            currentRetryAttempt += 1
                            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                                performRequest()
                            }
                        } else {
                            completion(.failure(.decodingError(error)))
                        }
                    }
                }.resume()
                
            }
            
            performRequest()
        }
        
        func cleanPrayerTime(_ input: String) -> String{
            let endIndex = input.index(input.startIndex, offsetBy: 5, limitedBy: input.endIndex) ?? input.endIndex
            let firstFive = input[..<endIndex]
            return String(firstFive)
        }

        sendRequest { result in
            switch result {
            case .success(let response):
                var arrayOfPrayerTimes = [PrayerTime]()
                
                for i in day..<response.data.count {
                    let curr = response.data[i].timings
                    
                    prayerTime = PrayerTime(date: formattedDate, cityName: city, asrTime: curr.Asr, ishaTime: curr.Isha, sunriseTime: curr.Sunrise, maghribTime: curr.Maghrib, dhuhrTime: curr.Dhuhr, fajrTime: curr.Fajr)
                    
                    if let prayerTime {
                        arrayOfPrayerTimes.append(prayerTime)
                    }
                }
                
                let todayData = response.data[day - 1].timings
                
                let fajr = cleanPrayerTime(todayData.Fajr)
                let sunrise = cleanPrayerTime(todayData.Sunrise)
                let dhuhr = cleanPrayerTime(todayData.Dhuhr)
                let asr = cleanPrayerTime(todayData.Asr)
                let maghrib = cleanPrayerTime(todayData.Maghrib)
                let isha = cleanPrayerTime(todayData.Isha)
                
                prayerTime = PrayerTime(date: formattedDate, cityName: city, asrTime: asr, ishaTime: isha, sunriseTime: sunrise, maghribTime: maghrib, dhuhrTime: dhuhr, fajrTime: fajr)
                
                self.selectedTab = .home
                self.isPrayerTimeReceived = true
                
                NotificationManager.shared.prayerTimes = arrayOfPrayerTimes
                NotificationManager.shared.reschedule()
                
            case .failure(let error):
                errorText = NSLocalizedString("no-internet-suggestion", bundle: globalData.bundle ?? Bundle.main, comment: "errors")
                print(error)
//                switch error {
//                case .invalidURL:
//                    errorText = NSLocalizedString("no-internet-suggestion", bundle: globalData.bundle ?? Bundle.main, comment: "errors")
//                case .httpError(let statusCode):
//                    errorText = NSLocalizedString("no-internet-suggestion", bundle: globalData.bundle ?? Bundle.main, comment: "errors")
//                case .noData:
//                    errorText = NSLocalizedString("no-internet-suggestion", bundle: globalData.bundle ?? Bundle.main, comment: "errors")
//                case .decodingError(let decodingError):
//                    errorText = NSLocalizedString("no-internet-suggestion", bundle: globalData.bundle ?? Bundle.main, comment: "errors")
//                case .other(let otherError):
//                    errorText = NSLocalizedString("no-internet-suggestion", bundle: globalData.bundle ?? Bundle.main, comment: "errors")
//                }
            }
            
        }


        }
        
//        func sendRequest() {
//            currentRetryAttempt += 1
//
//
//            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//                defer { self.isRequestInProgress = false }
//
//                if let error = error {
//                    if currentRetryAttempt < maxRetryAttempts {
//                        errorText = NSLocalizedString("no-internet-suggestion", bundle: globalData.bundle ?? Bundle.main, comment: "errors")
//                        print(error)
//                        sendRequest()
//                    } else {
//                        errorText = NSLocalizedString("no-internet-suggestion", bundle: globalData.bundle ?? Bundle.main, comment: "errors")
//                    }
//                    return
//                }
//
//                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
//                    errorText = NSLocalizedString("no-internet-suggestion", bundle: globalData.bundle ?? Bundle.main, comment: "errors")
//                    return
//                }
//
//                guard let data = data else {
//                    errorText = NSLocalizedString("no-internet-suggestion", bundle: globalData.bundle ?? Bundle.main, comment: "errors")
//                    return
//                }
//
//                do {
//                    let array = try JSONDecoder().decode([PrayerTime].self, from: data)
//
//                    guard let todayPrayerTime = array.first else {
//                        errorText = NSLocalizedString("no-internet-suggestion", bundle: globalData.bundle ?? Bundle.main, comment: "errors")
//                        return
//                    }
//
//                    self.prayerTime = todayPrayerTime
//                    self.city = todayPrayerTime.cityName
//                    self.selectedTab = .home
//                    self.isPrayerTimeReceived = true
//
//                    NotificationManager.shared.prayerTimes = array
//                    NotificationManager.shared.reschedule()
//
//                } catch {
//                    errorText = NSLocalizedString("no-internet-suggestion", bundle: globalData.bundle ?? Bundle.main, comment: "errors")
//                }
//            }
//
//            task.resume()
//        }
        
//        sendRequest()
//    }
    
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
                    errorText = NSLocalizedString("no-internet-suggestion", bundle: globalData.bundle ?? Bundle.main, comment: "errors")
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
