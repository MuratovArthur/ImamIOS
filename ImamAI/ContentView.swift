//  ContentView.swift
//  ImamAI
//  Created by Muratov Arthur on 03.07.2023.
//

import SwiftUI
import CoreLocation
import Combine

struct ContentView: View {
    enum Tab {
        case loading
        case home
        case other
        case settings
    }
    
    @StateObject var locationManager = LocationManager()
    @StateObject var scrollStore = ScrollPositionStore()
    @State private var selectedTab: Tab = .loading
    @State private var isLoadingComplete = false
    
    var initialTab: Tab {
        if locationManager.location != nil {
            return .home
        } else {
            return .loading
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                switch selectedTab {
                case .home:
                    HomeView(selectedTab: $selectedTab)
                        .environmentObject(scrollStore)
                        .navigationBarHidden(true)
                case .other:
                    ChatScreen(selectedTab: $selectedTab)
                        .navigationBarHidden(true)
                case .settings:
                    SettingsView()
                        .navigationBarHidden(true)
                default:
                    EmptyView()
                }
                Spacer()
            }
            .padding(.bottom, isLoadingComplete ? 50 : 0) // Adjust based on your TabBarView's height
            
            if isLoadingComplete {
                TabBarView(selectedTab: $selectedTab)
            }
            
            if selectedTab == .loading {
                LoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if locationManager.location != nil {
                    selectedTab = .home
                    isLoadingComplete = true
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

