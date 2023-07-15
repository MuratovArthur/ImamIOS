import SwiftUI

struct PrayerTimesView: View {
    let prayerTimes: [String: String] = [
        "Фаджр": "04:30",
        "Зухр": "13:00",
        "Аср": "17:00",
        "Магриб": "20:30",
        "Иша": "22:00"
    ]
    let order = ["Фаджр", "Зухр", "Аср", "Магриб", "Иша"]
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
                .font(.title)
                .fontWeight(.bold)

            ForEach(order.indices, id: \.self) { index in
                let key = order[index]
                let isMutedForPrayerTime = $isMuted[index]
                
                HStack {
                    Text(key)
                        .font(.subheadline)
                    Spacer()
                    Text(prayerTimes[key]!)
                        .font(.subheadline)
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

