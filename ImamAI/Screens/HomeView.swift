import SwiftUI
import CoreLocation

struct HomeView: View {
    let imageNames = ["IMAGE 1", "IMAGE 2", "IMAGE 3", "IMAGE 4", "IMAGE 2", "IMAGE 3"]
    let currentDate = Date()
    @State private var isChatOpen = false
    @State private var scrollToBottom = false // New state variable
    @State private var isEventListVisible = false
    @State private var scrollPosition: CGFloat = 0
    @Binding var selectedTab: ContentView.Tab
    @Binding var prayerTime: PrayerTime?
    @Binding var city: String // Change to @Binding
    @Binding var tabBarShouldBeHidden: Bool
    @Binding var useAlmatyLocation: Bool
    @State private var notificationAuthorizationStatus: UNAuthorizationStatus?
    @State private var showAlertForSettings = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(alignment: .center) {
                    
                    
                    ScrollViewReader { scrollViewProxy in
                        ScrollView(showsIndicators: false) {
                            
                            
                            CalendarButtonView(currentDate: currentDate)
                            
                            ImamChatPreview(selectedTab: $selectedTab)
                            
                            
                            
                            PrayerTimesView(prayerTime: prayerTime, city: city)
                            
                            PostsView(tabBarShouldBeHidden: $tabBarShouldBeHidden)
                            
                            Spacer()
                        }
                        
                        .padding(.top, 0.1)
                        .onChange(of: scrollToBottom) { newValue in
                            if newValue {
                                scrollViewProxy.scrollTo(imageNames.last, anchor: .trailing)
                                scrollToBottom = false
                            }
                        }
                        .onAppear {
                            checkPermissions()
                            print("HomeView appeared.")
                            print("prayerTimes: \(prayerTime)")
                            print("city: \(city)")
                            scrollToBottom = true
                            scrollViewProxy.scrollTo(scrollPosition)
                        }
                    }
                    
                }
                .alert(isPresented: $showAlertForSettings) {
                    Alert(
                        title: Text("Требуется действие"),
                        message: Text("Для использования всех функций, пожалуйста, предоставьте разрешения на определение местоположения и уведомления в настройках вашего устройства."),
                        primaryButton: .default(Text("Открыть настройки"), action: {
                            NotificationManager.shared.openAppSettings()
                        }),
                        secondaryButton: .cancel(Text("Отмена"))
                    )
                }
                .onAppear {
                    checkPermissions()
                }
               
            }
            .navigationBarHidden(true)
           
            
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    private func checkPermissions() {
        // Check notification permission
        NotificationManager.shared.getNotificationAuthorizationStatus { status in
            notificationAuthorizationStatus = status
            if status != .authorized {
                showAlertForSettings = true
            }
        }
        
        // Add any additional checks for location permission if needed
    }
}
//
//
//import SwiftUI
//
//struct HomeView: View {
//    @Binding var prayerTimes: [String: String]
//    @Binding var city: String
//
//    var body: some View {
//        VStack {
//            Text("Prayer Times")
//                .font(.title)
//                .fontWeight(.bold)
//                .padding(.top, 24)
//
//            ForEach(prayerTimes.sorted(by: <), id: \.key) { key, value in
//                PrayerTimeRow(prayerName: key, prayerTime: value)
//            }
//
//            Spacer()
//
//            Text("City: \(city)")
//                .font(.headline)
//                .padding(.bottom, 16)
//        }
//        .padding(.horizontal, 16)
//        .onReceive(NotificationCenter.default.publisher(for: .prayerTimesUpdated)) { notification in
//            if let userInfo = notification.userInfo as? [String: Any] {
//                print("Received prayerTimesUpdated notification with userInfo: \(userInfo)")
//                if let updatedPrayerTimes = userInfo["prayerTimes"] as? [String: String],
//                   let updatedCity = userInfo["cityName"] as? String {
//                    DispatchQueue.main.async {
//                        print("Updating prayer times and city in HomeView")
//                        self.prayerTimes = updatedPrayerTimes
//                        self.city = updatedCity
//                    }
//                }
//            }
//        }
//        .onAppear {
//                 print("HomeView appeared with data:")
//                 print("PrayerTimes: \(self.prayerTimes)")
//                 print("City: \(self.city)")
//             }
//    }
//}
//
//struct PrayerTimeRow: View {
//    var prayerName: String
//    var prayerTime: String
//
//    var body: some View {
//        HStack {
//            Text(prayerName)
//                .font(.headline)
//                .padding(.leading, 16)
//
//            Spacer()
//
//            Text(prayerTime) // Display the prayer time here
//                .font(.subheadline)
//                .padding(.trailing, 16)
//        }
//        .padding(.vertical, 8)
//    }
//}
