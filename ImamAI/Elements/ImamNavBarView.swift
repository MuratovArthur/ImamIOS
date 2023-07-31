import SwiftUI

struct ImamNavBarView: View {
    @ObservedObject private var viewModel = ChatViewModel.shared
    @Binding var sentOneMessage: Bool
    @State var randomInt = Int.random(in: 1...9)
    @Binding var showAlert: Bool
    
    var body: some View {
        HStack {
   
                Image("imam")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 3)
                
                VStack(alignment: .leading) {
                    Text("Имам")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    if sentOneMessage {
                        Text("онлайн")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    } else {
                        Text("был в сети \(randomInt) мин. назад")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.leading, 10)
            
            Spacer()
            
            Image(systemName: "trash")
                .font(.system(size: 20))
                .onTapGesture {
                                    showAlert = true
                                }
                
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        // Use this for side padding or adjust as needed.
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

//struct ImamNavBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        // For demonstration purposes, I'm assuming the `sentOneMessage` is `true` here.
//        // You can change it to `false` if you want to see the other state.
//        ImamNavBarView(sentOneMessage: .constant(true), showAlert: false)
//            .previewLayout(.sizeThatFits)
//            .background(Color.gray) // Change this to the desired background color for the preview.
//            .padding()
//    }
//}
