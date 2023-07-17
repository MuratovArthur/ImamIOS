import SwiftUI

struct ContentView: View {
    enum Tab {
        case loading
        case home
        case other
        case settings
    }
    
    @StateObject var locationManager = LocationManager()
    @StateObject var scrollStore = ScrollPositionStore()
    @State private var selectedTab: Tab = .loading
    @State private var isLoadingComplete = false
    @State private var prayerTimes: [String: String] = [:]
    @State private var city: String = ""
    
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
            .padding(.bottom, isLoadingComplete ? 50 : 0) // Adjust based on your TabBarView's height
            
            if isLoadingComplete {
                TabBarView(selectedTab: $selectedTab)
            }
            
            if selectedTab == .loading {
                LoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            makeRequest()
        }
        .onChange(of: locationManager.location) { newLocation in
            if newLocation != nil && selectedTab == .loading {
                makeRequest()
            }
        }
    }

    func makeRequest() {
        guard let location = locationManager.location else {
            return
        }
        
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        
//        let latitude = "42"
//        let longitude = "69"

        let url = URL(string: "https://fastapi-s53t.onrender.com/imam/get_time")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = ["lat": latitude, "lon": longitude]
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        
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
                    self.prayerTimes = prayerTimesData.prayerTimes
                    self.selectedTab = .home
                    self.isLoadingComplete = true
                    self.city = prayerTimesData.cityName
                }
            } catch {
                print("Error decoding prayer times data: \(error)")
            }
        }.resume()
    }
}

struct PrayerTimesData: Codable {
    let cityName: String
    let fajrTime: String
    let sunriseTime: String
    let dhuhrTime: String
    let asrTime: String
    let maghribTime: String
    let ishaTime: String

    var prayerTimes: [String: String] {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
