import SwiftUI
import MapKit

struct CitySearchView: View {
    @State private var searchText = ""
    @State private var mapItems: [MKMapItem] = []
    @State private var selectedLocation: MKMapItem?
    @EnvironmentObject private var globalData: GlobalData
    @Environment(\.presentationMode) var presentationMode
    @Binding var tabBarShouldBeHidden: Bool
    
    var body: some View {
        VStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
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
                    let city = mapItem.placemark.name ?? "Almaty"
                    let country = getCountryFromString(inputString: mapItem.placemark.title ?? "Kazakhstan")
                    
                    updateLocationData(city: city, country: country)
                    presentationMode.wrappedValue.dismiss()
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
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .onAppear(){
            tabBarShouldBeHidden = true
        }
        .onDisappear(){
            tabBarShouldBeHidden = false
        }
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


//struct CitySearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        CitySearchView()
//    }
//}
