//
//  LocationPickerView.swift
//  ImamAI
//
//  Created by Nurali Rakhay on 14.08.2023.
//

import SwiftUI
import MapKit

struct LocationPickerView: View {
    @State private var searchText = ""
    @State private var mapItems: [MKMapItem] = []
    @State private var timer: Timer?

    var body: some View {
        VStack {
            TextField("Search for a city", text: $searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: searchText, perform: { newSearchText in
                    timer?.invalidate()
                    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        searchCities()
                    }
                })

            List(mapItems, id: \.self) { mapItem in
                VStack(alignment: .leading) {
                    Text(mapItem.placemark.name ?? "")
                        .font(.headline)
                    Text(mapItem.placemark.title ?? "")
                        .font(.subheadline)
                }
            }
            .listStyle(PlainListStyle())
            .padding()
            
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

struct LocationPickerView_Previews: PreviewProvider {
    static var previews: some View {
        LocationPickerView()
    }
}
