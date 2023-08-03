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
    private let languages = ["English", "Arabian", "Kazakh", "Russian"]
    
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
                        print("Language switched to \(globalData.appLanguage.rawValue)")
                    } label: {
                        Text(language.rawValue)
                        Spacer()
                        language.rawValue == globalData.appLanguage.rawValue ? Image(systemName: "checkmark") : nil
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
