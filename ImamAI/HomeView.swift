import SwiftUI
import CoreLocation


let posts = [
    Post(title: "Как помощь другим смягчает наши сердца", imageName: "post3", description: "Мягкий, добрый к людям человек достигает таких вещей, которых не достигнет жестокий и грубый. Постоянное совершение даже небольших благих дел поможет смягчить наши сердца и приблизить нас к Аллаху. Еще лучше, если эти дела войдут в привычку. Некоторые даже не задумываются о том, что их сердце стало черствым. Поэтому стремление совершать благие деяния, или хотя бы попытка их совершить может помочь человеку избежать подобного состояния."),
    Post(title: "Хотеть Ламборгини это харам?", imageName: "post2", description: "Часто можно слышать, что покупка дорогих вещей, например, дорогая машина – это харам. Но так ли это? На самом деле, все зависит от обстоятельств. Если вы заработали деньги дозволенным путем, не тратили их на запретные вещи, то нет никаких проблем с покупкой таких вещей. Но также необходимо подумать о намерении покупки."),
    Post(title: "Ислам и вегетарианство", imageName: "post1", description: "Начнем издалека. Пророк (мир ему и благословение Аллаха) сказал: (Что же касается) превосходства ‘Аиши над женщинами, то, поистине, оно подобно превосходству сарида над прочими (видами) еды»."),
]

struct HomeView: View {
    let imageNames = ["IMAGE 1", "IMAGE 2", "IMAGE 3", "IMAGE 4", "IMAGE 2", "IMAGE 3"]
    let currentDate = Date()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .medium
        return formatter
    }()
    @StateObject private var chatHelper = ChatHelper()
    @State private var isChatOpen = false
    @State private var scrollToBottom = false // New state variable
    @State private var isEventListVisible = false
    @State private var scrollPosition: CGFloat = 0
    @Binding var selectedTab: ContentView.Tab
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Button(action: {
                    isEventListVisible.toggle()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(Color(UIColor.systemGray6))
                            .frame(width: UIScreen.main.bounds.width * 0.6,
                                   height: UIScreen.main.bounds.height * 0.05)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .font(.subheadline)
                                .padding(.leading)
                            
                            Text(dateFormatter.string(from: currentDate))
                                .font(.body)
                                .padding(.trailing)
                        }
                    }
                    .padding(8)
                    .foregroundColor(Color.black)
                }
                .sheet(isPresented: $isEventListVisible) {
                    IslamicEventListView(events: events)
                }
                
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text("Ассаламу Алейкум!")
                                .font(.title)
                                .bold()
                                .padding()
                                .multilineTextAlignment(.leading)
                            
                            Text("Мы ниспослали тебе Писание для разъяснения всякой вещи, как руководство к прямому пути, милость и благую весть для мусульман (16:89).")
                                .font(.body)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                                .padding(.bottom)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .frame(width: UIScreen.main.bounds.width)
                        
                        PrayerTimesView()
                            .padding(.horizontal)
                        
                        VStack() {
                            Text("Ваш персональный Имам")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            HStack {
                                Spacer()
                                Image("imam-hello")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: UIScreen.main.bounds.width / 2.7)
                                    .cornerRadius(10)
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("С ImamAI вы можете задавать любые вопросы, связанные с Исламом, будь то о Коране, Хадисах, исламском учении или общих знаниях.")
                                        .font(.subheadline)
                                }
                                
                                Spacer()
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            
                            Button(action: {
                                selectedTab = .other
                            }) {
                                Text("Задайте вопрос Имаму!")
                                    .font(.headline)
                                    .padding(.vertical)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(UIColor.black))
                                    .foregroundColor(Color.white)
                                    .cornerRadius(10)
                                    .padding(.horizontal, 16)
                            }
                            Text("Для прочтения")
                                .font(.title)
                                .bold()
                                .padding()
                                .multilineTextAlignment(.leading)
                            
                            PostsView(posts: posts)
                            Spacer()
                        }
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
//            .sheet(isPresented: $isChatOpen) {
//                ChatScreen()
//            }
            .preferredColorScheme(.light)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}



//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView(selectedTab: ContentView.Tab.home)
//    }
//}
