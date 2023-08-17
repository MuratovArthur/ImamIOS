//
//  PrayerMethodPickerView.swift
//  ImamAI
//
//  Created by Nurali Rakhay on 16.08.2023.
//

import SwiftUI

struct PrayerMethodPickerView: View {
    @EnvironmentObject private var globalData: GlobalData
    
    let methods = ["Shia Ithna-Ansari",
                   "University of Islamic Sciences, Karachi",
                   "Islamic Society of North America",
                   "Muslim World League",
                   "Umm Al-Qura University, Makkah",
                   "Egyptian General Authority of Survey",
                   "Institute of Geophysics, University of Tehran",
                   "Gulf Region",
                   "Kuwait",
                   "Qatar",
                   "Majlis Ugama Islam Singapura, Singapore",
                   "Union Organization islamic de France",
                   "Diyanet İşleri Başkanlığı, Turkey",
                   "Spiritual Administration of Muslims of Russia",
    ]
    
    var body: some View {
        Menu {
            Text("Prayer times calculation method")
                .font(.headline)
                .foregroundColor(.gray)
            
            ForEach(methods, id: \.self) { method in
                Button {
                    var index = -1
                    for i in 0..<methods.count {
                        if method == methods[i] {
                            index = i
                        }
                    }
                    
                    globalData.prayerTimeMethod = index
                    UserDefaultsManager.shared.setPrayerTimeMethod(index)
                } label: {
                    Text(method)
                    Spacer()
                    
                    if let methodFromCache = UserDefaultsManager.shared.getPrayerTimeMethod() {
                        if methods[methodFromCache] == method {
                            Image(systemName: "checkmark")
                        }
                    } else {
                        if methods[globalData.prayerTimeMethod] == method {
                            Image(systemName: "checkmark")
                        }
                    }
                }

            }

        } label: {
            Image(systemName: "gearshape")
                .foregroundColor(.black)
                .font(.system(size: 20))
        }
    }
}

struct PrayerMethodPickerView_Previews: PreviewProvider {
    static var previews: some View {
        PrayerMethodPickerView()
    }
}
