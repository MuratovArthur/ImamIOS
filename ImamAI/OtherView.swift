import SwiftUI

struct OtherView: View {
    var body: some View {
//        NavigationView {
//            VStack {
//                Spacer()
//
//                NavigationLink(destination: ChatScreen()) {
//                    Text("Open Chat Screen")
//                        .font(.title)
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                }
//                .padding()
//
//                Spacer()
//            }
//            .navigationTitle("Other View")
//        }
        Text("Other")
            .font(.largeTitle)
    }
}

struct OtherView_Previews: PreviewProvider {
    static var previews: some View {
        OtherView()
    }
}
