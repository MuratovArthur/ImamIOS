import SwiftUI
import UserNotifications

@main
struct ImamAIApp: App {
    let center = UNUserNotificationCenter.current()
    let notificationDelegate = NotificationDelegate()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .navigationBarHidden(true)
        }
    }
}
