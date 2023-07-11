//  ContentView.swift
//  ImamAI
//  Created by Muratov Arthur on 03.07.2023.
//

import SwiftUI
import CoreLocation

class ScrollPositionStore: ObservableObject {
    @Published var position: CGFloat = 0
}


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Check the timestamp of the location, only accept it if it's recent (less than 15 seconds old in this example)
        if location.timestamp.timeIntervalSinceNow < -15 {
            return
        }

        self.location = location
        manager.stopUpdatingLocation()
    }
}


struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @StateObject var scrollStore = ScrollPositionStore() // Create an instance of ScrollPositionStore
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case other
        case settings
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                NavigationView {
                    VStack(spacing: 0) {
                        Spacer()
                        if locationManager.location != nil {
                            switch selectedTab {
                            case .home:
                                HomeView(selectedTab: $selectedTab)
                                    .environmentObject(scrollStore)
                                    .navigationBarHidden(true)
                            case .other:
                                OtherView()
                                    .navigationBarHidden(true)
                            case .settings:
                                SettingsView()
                                    .navigationBarHidden(true)
                            }
                            
                        } else {
                            Text("Fetching Location...")
                        }
                        Spacer()
                        
                        Divider()
                        
                        HStack() {
                            Spacer()
                            TabBarButton(tab: .home, imageName: "house.fill", selectedTab: $selectedTab)
                            Spacer()
                            TabBarButton(tab: .other, imageName: "message", selectedTab: $selectedTab)
                            Spacer()
                            TabBarButton(tab: .settings, imageName: "gear", selectedTab: $selectedTab)
                            Spacer()
                        }
                        .padding()
                        .padding(.bottom, 20)
                        .background(Color.white)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                }
                
                // Floating action button
//                Button(action: {
//                    // Button action
//                }) {
//                    Image(systemName: "message.circle")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 56, height: 56)
//                        .foregroundColor(Color.blue)
//                        .shadow(radius: 4)
//                }
//                .padding()
//                .offset(x: -geometry.size.width * 0.03, y: -geometry.size.height * 0.07) // Adjust offset as needed
            }
        }
    }
}

struct TabBarButton: View {
    let tab: ContentView.Tab
    let imageName: String
    @Binding var selectedTab: ContentView.Tab

    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            Image(systemName: imageName)
                .font(.title)
                .foregroundColor(tab == selectedTab ? .black : .gray)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
