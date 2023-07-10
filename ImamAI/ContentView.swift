//
//  ContentView.swift
//  ImamAI
//
//  Created by Muratov Arthur on 03.07.2023.
//

import SwiftUI


struct ContentView: View {
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home
        case other
        case settings
    }
    
    

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            switch selectedTab {
            case .home:
                HomeView()
            case .other:
                OtherView()
            case .settings:
                SettingsView()
            }

            Spacer()
            
            Divider()

            HStack() {
                
                Spacer()
                
                TabBarButton(tab: .home, imageName: "house.fill", selectedTab: $selectedTab)
                Spacer()
                TabBarButton(tab: .other, imageName: "moon", selectedTab: $selectedTab)
                Spacer()
                TabBarButton(tab: .settings, imageName: "gear", selectedTab: $selectedTab)
                Spacer()
            }
            .padding()
            .padding(.bottom, 20)
            .background(Color.white)
        }
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
                .font(.title)
                .foregroundColor(tab == selectedTab ? .black : .gray)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
