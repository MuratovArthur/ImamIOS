import SwiftUI

struct PrayerTimesView: View {
    let prayerTimes: [String: String] = [
        "Fajr": "04:30",
        "Dhuhr": "13:00",
        "Asr": "17:00",
        "Maghrib": "20:30",
        "Isha": "22:00"
    ]
    let order = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
    let country = "Казахстан"
    let city = "Алматы"

    @State private var isMuted: [Bool] = Array(repeating: false, count: 5)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "location")
                Text("\(country), \(city)")
                    .font(.subheadline)
            }
            .padding(.top, 16)

            Text("Время намаза")
                .font(.largeTitle)
                .fontWeight(.bold)

            ForEach(order.indices, id: \.self) { index in
                let key = order[index]
                let isMutedForPrayerTime = $isMuted[index]
                
                HStack {
                    Text(key)
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Text(prayerTimes[key]!)
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Button(action: {
                        isMutedForPrayerTime.wrappedValue.toggle()
                    }) {
                        Image(systemName: isMutedForPrayerTime.wrappedValue ? "speaker.slash" : "speaker.wave.2")
                            .font(.subheadline)
                            .foregroundColor(Color.black)
                    }
                }
//                .padding(.horizontal, 16)
            }

            Spacer()
        }
        
        .padding(.horizontal)
//        .navigationBarTitle("Prayer Times", displayMode: .inline)
    }
}

struct PrayerTimesView_Previews: PreviewProvider {
    static var previews: some View {
        PrayerTimesView()
    }
}

