//
//  HomeHeaderView.swift
//  ImamAI
//
//  Created by Nurali Rakhay on 03.08.2023.
//

import SwiftUI

struct HomeHeaderView: View {
    let currentDate = Date()
    @State private var isMenuVisible = false
    @EnvironmentObject private var globalData: GlobalData
    
    var body: some View {
        HStack {
            CalendarButtonView(currentDate: currentDate)
                .padding(.horizontal, 10)
            
            Spacer()
            
            Menu {
                
                Text("Select Language")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                ForEach(Language.allCases, id: \.self) { language in
                    Button {
                        globalData.appLanguage = language
                        let locale = GlobalData.decideLocale(lang: language)
                        globalData.locale = locale
                        UserDefaultsManager.shared.setLanguage(locale)
                        NotificationManager.shared.reschedule(language: globalData.locale)
                        print("Language switched to \(globalData.appLanguage.rawValue)")
                    } label: {
                        Text(language.rawValue)
                        Spacer()
                        
                        
                        
                        if let locale = UserDefaultsManager.shared.getLanguage() {
                            if language.rawValue == GlobalData.decideLanguageFromLocale(locale: locale) {
                                Image(systemName: "checkmark")
                            }
                        } else if GlobalData.decideLocale(lang: language) == globalData.locale {
                            Image(systemName: "checkmark")
                        }
                    }
                    
                }
            } label: {
                Image(systemName: "globe")
                    .foregroundColor(.black)
                    .font(.system(size: 25))
            }
            .padding(.horizontal, 14)
            
            //            Button {
            //                isMenuVisible.toggle()
            //            } label: {
            //                Image(systemName: "globe")
            //                    .foregroundColor(.black)
            //                    .font(.system(size: 25))
            //            }
            //            .padding(.horizontal, 14)
            //            .contextMenu {
            //                Button {
            //                    print("Change country setting")
            //                } label: {
            //                    Label("Choose Country", systemImage: "globe")
            //                }
            //
            //                Button {
            //                    print("Enable geolocation")
            //                } label: {
            //                    Label("Detect Location", systemImage: "location.circle")
            //                }
            //            }
            
        }
    }
}


struct HomeHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HomeHeaderView()
    }
}
