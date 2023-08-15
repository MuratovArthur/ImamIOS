//
//  LocationPickerView.swift
//  ImamAI
//
//  Created by Nurali Rakhay on 14.08.2023.
//

import SwiftUI
import MapKit

struct CitySearchView: View {
    @State private var searchText = ""
    @State private var mapItems: [MKMapItem] = []
    @State private var selectedLocation: MKMapItem?
    @EnvironmentObject private var globalData: GlobalData
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title)
                    .foregroundColor(Color.black)
                
                Spacer()
            }
            .padding(.leading, 16)
            
            
            TextField("Search for a city", text: $searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: searchText) { _ in
                    searchCities()
                }
            
            List(mapItems, id: \.self) { mapItem in
                Button(action: {
                    if selectedLocation == mapItem {
                        selectedLocation = nil
                    } else {
                        selectedLocation = mapItem
                    }
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(mapItem.placemark.name ?? "")
                                .font(.headline)
                            Text(mapItem.placemark.title ?? "")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        if mapItem.placemark.name == selectedLocation?.name,
                           mapItem.placemark.title == selectedLocation?.placemark.title
                        {
                            Image(systemName: "checkmark")
                        }
                        
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Spacer()
            
            Button(action: {
                if let selectedLocation = selectedLocation {
                    let city = selectedLocation.placemark.name ?? "Almaty"
                    let country = getCountryFromString(inputString: selectedLocation.placemark.title ?? "Kazakhstan")
                    
                    updateLocationData(city: city, country: country)
                }
            }) {
                Text("Save", bundle: globalData.bundle)
                    .font(.headline)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.black))
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
            }
            
            Spacer()
        }
        .background(Color.white)
        //        .navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true) // Hide default back button
        //        .navigationBarItems(leading: Image(systemName: "chevron.left")) // Set custom back button
    }
    
    private func searchCities() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            if let mapItems = response?.mapItems {
                self.mapItems = mapItems
            }
        }
    }
    
    private func updateLocationData(city: String, country: String) {
        globalData.country = country
        globalData.city = city
        
        UserDefaultsManager.shared.setCity(city)
        UserDefaultsManager.shared.setCountry(country)
    }
    
    private func getCountryFromString(inputString: String) -> String {
        var idx = inputString.endIndex
        var commaSeen = false
        
        while idx > inputString.startIndex {
            idx = inputString.index(before: idx)
            
            let currentCharacter = inputString[idx]
            
            if currentCharacter == "," {
                commaSeen = true
                break
            }
            
        }
        
        if commaSeen {
            return String(inputString[inputString.index(idx, offsetBy: 2)...])
        } else {
            return String(inputString[idx...])
        }
    }
}


struct CitySearchView_Previews: PreviewProvider {
    static var previews: some View {
        CitySearchView()
    }
}
