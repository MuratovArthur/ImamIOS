//
//  LocationSwitchView.swift
//  ImamAI
//
//  Created by Nurali Rakhay on 18.08.2023.
//

import SwiftUI

struct LocationSwitchView: View {
    @EnvironmentObject private var globalData: GlobalData
    @Binding var usersCurrCity: String
    @Binding var usersCurrCountry: String
    @Binding var shouldShowLocationSheet: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(NSLocalizedString("mainText", bundle: globalData.bundle ?? Bundle.main, comment: "location switch request"))
                    .font(.body)
                Spacer()
            }
            
            HStack(spacing: 12) {
                Image(systemName: "location")
                    .font(.title)
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(usersCurrCity)
                        .font(.headline)
                    Text(usersCurrCountry)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            Button(action: {
                updateLocationData(city: usersCurrCity, country: usersCurrCountry)
                shouldShowLocationSheet = false
            }) {
                Text(NSLocalizedString("switch", bundle: globalData.bundle ?? Bundle.main, comment: "location switch request"))
                    .tracking(2)  
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black)
                    .cornerRadius(10)
                    
            }
            .frame(maxWidth: .infinity) // Set the button's width to fill the available space
            
            Button(action: {
                shouldShowLocationSheet = false
            }) {
                Text(NSLocalizedString("close", bundle: globalData.bundle ?? Bundle.main, comment: "location switch request"))
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
                
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)

    }
    
    private func updateLocationData(city: String, country: String) {
        globalData.country = country
        globalData.city = city
        
        UserDefaultsManager.shared.setCity(city)
        UserDefaultsManager.shared.setCountry(country)
    }
}

