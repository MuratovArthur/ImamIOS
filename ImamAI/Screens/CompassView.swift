import SwiftUI
import CoreLocation

struct CompassView: View {
    @ObservedObject var locationManager = LocationManager()
    let currentDate = Date()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            
            HStack{
                Spacer()
                CalendarButtonView(currentDate: currentDate)
                Spacer()
            }
            
            Text("Поиск Киблы")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Spacer()
            
            HStack {
                Spacer()
                
                Image("compass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .rotationEffect(Angle(degrees: locationManager.qiblaDirection - locationManager.deviceHeading))
                
                Spacer()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .onAppear {
            locationManager.startUpdating()
        }
        .onDisappear {
            locationManager.stopUpdating()
        }
    }
}

struct CompassView_Previews: PreviewProvider {
    static var previews: some View {
        CompassView()
    }
}
