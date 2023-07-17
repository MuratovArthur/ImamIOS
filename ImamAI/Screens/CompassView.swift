import SwiftUI
import CoreLocation

struct CompassView: View {
    @ObservedObject var locationManager = LocationManager()

    var body: some View {
        VStack(alignment: .leading) {
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
                    .frame(width: 300, height: 300)
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
