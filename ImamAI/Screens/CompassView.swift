import SwiftUI
import CoreLocation

struct CompassView: View {
    @ObservedObject var locationManager = LocationManager()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let currentDate = Date()
    
    var backButton: some View {
        Button(action: {
                self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.black)
                }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("qibla-search", comment: "compass view"))
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            HStack {
                Spacer()
                
                Image("compass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
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
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
        
}

struct CompassView_Previews: PreviewProvider {
    static var previews: some View {
        CompassView()
    }
}
