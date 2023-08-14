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
    @State private var selectedCity: MKMapItem?
    
    var body: some View {
        VStack {
            TextField("Search for a city", text: $searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: searchText) { _ in
                    searchCities()
                }
            
            List(mapItems, id: \.self) { mapItem in
                Button(action: {
                    if selectedCity == mapItem {
                        selectedCity = nil
                    } else {
                        selectedCity = mapItem
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
                        
                        if mapItem.placemark.name == selectedCity?.name,
                           mapItem.placemark.title == selectedCity?.placemark.title
                        {
                            Image(systemName: "checkmark")
                        }
                        
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            Spacer()
        }
        .background(Color.white)
    }
    
    func searchCities() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            if let mapItems = response?.mapItems {
                self.mapItems = mapItems
            }
        }
    }
}

struct CitySearchView_Previews: PreviewProvider {
    static var previews: some View {
        CitySearchView()
    }
}
