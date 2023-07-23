import SwiftUI
import UserNotifications

@main
struct ImamAIApp: App {
    let center = UNUserNotificationCenter.current()
    let notificationDelegate = NotificationDelegate()

    init() {
        center.delegate = notificationDelegate
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            } else if granted {
                print("Notification authorization granted.")
            } else {
                print("Notification authorization denied.")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .navigationBarHidden(true)
        }
    }
}
