import SwiftUI
import UserNotifications

@main
struct ImamAIApp: App {
    let center = UNUserNotificationCenter.current()
    let notificationDelegate = NotificationDelegate()
    @StateObject var globalData = GlobalData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .navigationBarHidden(true)
                .environmentObject(globalData)
                .environment(\.layoutDirection, globalData.locale == "ar" ? .rightToLeft : .leftToRight)
                .environment(\.locale, Locale(identifier: globalData.locale))
        }
    }
}
