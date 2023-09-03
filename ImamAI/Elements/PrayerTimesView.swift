import SwiftUI

struct PrayerTimesView: View {
    let prayerTime: PrayerTime?
    let order = ["Фаджр","Восход", "Зухр", "Аср", "Магриб", "Иша"]

    let country = NSLocalizedString("default-country", comment: "prayer times view")
    let city: String

    @EnvironmentObject private var globalData: GlobalData
    @State private var isMuted: [Bool] = UserDefaultsManager.shared.getIsMuted() ?? Array(repeating: false, count: 6)
    @Binding var tabBarShouldBeHidden: Bool
    @Binding var suggestingNewLocation: Bool
    

    var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    NavigationLink(destination:
                                    CitySearchView(tabBarShouldBeHidden: $tabBarShouldBeHidden, suggestingNewLocation: $suggestingNewLocation)
                                        .environmentObject(globalData)
//                                        .navigationBarHidden(true)
                    ) {
                        HStack {
                            Image(systemName: "location")
                            Text("\(globalData.country), \(globalData.city)")
                                .font(.subheadline)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .foregroundColor(.black)
                    
                    Spacer()
                    
                    PrayerMethodPickerView(suggestingNewLocation: $suggestingNewLocation)
                }
                .padding(.top, 16)
                
                Text("prayer-time", bundle: globalData.bundle)
                    .font(.title)
                    .fontWeight(.bold)

                ForEach(order, id: \.self) { key in
                    let index = order.firstIndex(of: key) ?? 0
                    let isMutedForPrayerTime = $isMuted[index]

                    HStack {
    //                    Text("\(key)", bundle: globalData.bundle)
                        Text(NSLocalizedString("\(key)", bundle: globalData.bundle ?? Bundle.main, comment: "prayer times view"))
                            .font(.subheadline)
                        Spacer()
                        Text((prayerTime?.orderedValues[key] ?? "") ?? "")
                            .font(.subheadline)
                        Button(action: {
                            isMutedForPrayerTime.wrappedValue.toggle()
                            UserDefaultsManager.shared.updateMutedStatus(for: key, isMuted: isMutedForPrayerTime.wrappedValue)
                            NotificationManager.shared.reschedule(language: globalData.locale)
                        }) {
                            Image(systemName: isMutedForPrayerTime.wrappedValue ? "bell.slash" : "bell.badge")
                                .font(.subheadline)
                                .foregroundColor(Color.black)
                        }
                        .frame(width: 30, alignment: .trailing) // Set the fixed width of your button here.
                    }
                }

            }
            .padding(.horizontal)
        }
}

//struct PrayerTimesView: View {
//    let prayerTime: PrayerTime?
//    let order = ["Фаджр", "Восход", "Зухр", "Аср", "Магриб", "Иша"]
//
//    @State private var country: String = UserDefaultsManager.shared.getCountry() ?? NSLocalizedString("default-country", comment: "prayer times view")
//    @State private var city: String = UserDefaultsManager.shared.getCity() ?? "" // Load city from UserDefaults
//
//    @State private var isMuted: [Bool] = UserDefaultsManager.shared.getIsMuted() ?? Array(repeating: false, count: 6)
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            HStack {
//                Image(systemName: "location")
//                TextField("Country", text: $country)
//                    .font(.subheadline)
//            }
//            .padding(.top, 16)
//
//            TextField("City", text: $city)
//                .font(.subheadline)
//
//            Text(NSLocalizedString("prayer-time", comment: "prayer times view"))
//                .font(.title)
//                .fontWeight(.bold)
//
//            ForEach(order, id: \.self) { key in
//                let index = order.firstIndex(of: key) ?? 0
//                let isMutedForPrayerTime = $isMuted[index]
//
//                HStack {
//                    Text(NSLocalizedString(key, comment: "prayer times view"))
//                        .font(.subheadline)
//                    Spacer()
//                    Text((prayerTime?.orderedValues[key] ?? "") ?? "")
//                        .font(.subheadline)
//                    Button(action: {
//                        isMutedForPrayerTime.wrappedValue.toggle()
//                        UserDefaultsManager.shared.updateMutedStatus(for: key, isMuted: isMutedForPrayerTime.wrappedValue)
//                        NotificationManager.shared.reschedule()
//                    }) {
//                        Image(systemName: isMutedForPrayerTime.wrappedValue ? "bell.slash" : "bell.badge")
//                            .font(.subheadline)
//                            .foregroundColor(Color.black)
//                    }
//                    .frame(width: 30, alignment: .trailing) // Set the fixed width of your button here.
//                }
//            }
//            Spacer()
//        }
//        .padding(.horizontal)
//        .onDisappear(perform: {
//            UserDefaultsManager.shared.saveCountry(country)
//            UserDefaultsManager.shared.saveCity(city)
//        })
//    }
//}
//
