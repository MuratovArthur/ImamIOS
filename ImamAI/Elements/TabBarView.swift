import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: ContentView.Tab
    
    var body: some View {
        Spacer()
        VStack {
            HStack {
                Spacer()
                TabBarButton(tab: .home, imageName: "house.fill", selectedTab: $selectedTab)
                Spacer()
                TabBarButton(tab: .other, imageName: "message", selectedTab: $selectedTab)
                Spacer()
                TabBarButton(tab: .settings, imageName: "safari", selectedTab: $selectedTab)
                Spacer()
            }
            .padding(.horizontal)
            .background(Color.white)
        }
        .background((Color(UIColor.systemGray6)))
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct TabBarButton: View {
    let tab: ContentView.Tab
    let imageName: String
    @Binding var selectedTab: ContentView.Tab
    
    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            Image(systemName: imageName)
                .font(.system(size: 20))
                .foregroundColor(tab == selectedTab ? .black : .gray)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(selectedTab: .constant(.home))
    }
}
