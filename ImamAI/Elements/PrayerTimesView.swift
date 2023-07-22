import SwiftUI

struct PrayerTimesView: View {
    let prayerTimes: [String: String]
    let order = ["Фаджр","Восход", "Зухр", "Аср", "Магриб", "Иша"]
    let country = "Казахстан"
    let city: String
    
    @State private var isMuted: [Bool] = UserDefaultsManager.shared.getIsMuted() ?? Array(repeating: false, count: 6)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "location")
                Text("\(country), \(city)")
                    .font(.subheadline)
            }
            .padding(.top, 16)
            
            Text("Время намаза")
                .font(.title)
                .fontWeight(.bold)
            
            ForEach(order, id: \.self) { key in
                            let index = order.firstIndex(of: key) ?? 0
                            let isMutedForPrayerTime = $isMuted[index]

                            HStack {
                                Text(key)
                                    .font(.subheadline)
                                Spacer()
                                Text(prayerTimes[key] ?? "")
                                    .font(.subheadline)
                                Button(action: {
                                    isMutedForPrayerTime.wrappedValue.toggle()
                                    UserDefaultsManager.shared.updateMutedStatus(for: key, isMuted: isMutedForPrayerTime.wrappedValue)
//                                    NotificationManager.shared.scheduleNotificationIfNeeded(prayerTime: key, isMuted: isMutedForPrayerTime.wrappedValue, prayerTimes: prayerTimes)
                                }) {
                                    Image(systemName: isMutedForPrayerTime.wrappedValue ? "speaker.slash" : "speaker.wave.2")
                                        .font(.subheadline)
                                        .foregroundColor(Color.black)
                                }
                            }
            };            Spacer()
            
        }
        .padding(.horizontal)
    }
}
