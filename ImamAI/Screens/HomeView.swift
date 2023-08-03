import SwiftUI
import CoreLocation

struct HomeView: View {
    let imageNames = ["IMAGE 1", "IMAGE 2", "IMAGE 3", "IMAGE 4", "IMAGE 2", "IMAGE 3"]
    @EnvironmentObject private var globalData: GlobalData
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
    @Binding var firstTimeInApp: Bool
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(alignment: .center) {
                    ScrollViewReader { scrollViewProxy in
                        ScrollView(showsIndicators: false) {
                            HomeHeaderView()
                            
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
                        title: Text(NSLocalizedString("action-required", comment: "alerts")),
                        message: Text(NSLocalizedString("internet-alert", comment: "alerts")),
                        primaryButton: .default(Text(NSLocalizedString("open-settings", comment: "alerts")), action: {
                            DispatchQueue.main.async {
                                NotificationManager.shared.openAppSettings()
                            }
                        }),
                        secondaryButton: .cancel(Text(NSLocalizedString("cancel", comment: "alerts")))
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
            if status != .authorized, firstTimeInApp {
                showAlertForSettings = true
                firstTimeInApp = false
            }
        }
        
        // Add any additional checks for location permission if needed
    }
}
