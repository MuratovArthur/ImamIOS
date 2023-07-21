import SwiftUI
import CoreLocation

struct HomeView: View {
    let imageNames = ["IMAGE 1", "IMAGE 2", "IMAGE 3", "IMAGE 4", "IMAGE 2", "IMAGE 3"]
    let currentDate = Date()
    @State private var isChatOpen = false
    @State private var scrollToBottom = false // New state variable
    @State private var isEventListVisible = false
    @State private var scrollPosition: CGFloat = 0
    @Binding var selectedTab: ContentView.Tab
    let prayerTimes: [String: String]
    let city: String
    
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(alignment: .center) {
                    CalendarButtonView(currentDate: currentDate)
                    
                    
                    ScrollViewReader { scrollViewProxy in
                        ScrollView (showsIndicators: false) {
                            ImamChatPreview(selectedTab: $selectedTab)
                            
//                                                        PrayerTimesView(
//                                                            prayerTimes: [
//                                                                "Фаджр": "11:33",
//                                                                "Восход": "11:34",
//                                                                "Зухр": "11:35",
//                                                                "Аср": "11:36",
//                                                                "Магриб": "11:37",
//                                                                "Иша": "11:38"
//                                                            ],
//                                                            city: "Алматы"
//
//                                                    )
                            
                            PrayerTimesView(prayerTimes: prayerTimes, city: city)

                            PostsView()
                            
                            
                            Spacer()
                            
                        }
                        .onChange(of: scrollToBottom) { newValue in
                            if newValue {
                                scrollViewProxy.scrollTo(imageNames.last, anchor: .trailing)
                                scrollToBottom = false
                            }
                        }
                        .onAppear {
                            scrollToBottom = true
                            scrollViewProxy.scrollTo(scrollPosition)
                        }
                        
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectedTab: .constant(.home), prayerTimes: ["1": "2"], city: "Алматы")
    }
}
