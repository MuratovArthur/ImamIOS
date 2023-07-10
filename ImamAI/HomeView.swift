//
//  HomeView.swift
//  ImamAI
//
//  Created by Muratov Arthur on 03.07.2023.
//

import SwiftUI

struct HomeView: View {
    let imageNames = ["IMAGE 1", "IMAGE 2", "IMAGE 3", "IMAGE 4", "IMAGE 5"]
    let currentDate = Date()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .medium
        return formatter
    }()
    @StateObject private var chatHelper = ChatHelper()
    
    
    @State private var isChatOpen = false
    var body: some View {
        
        GeometryReader { geometry in
            VStack(alignment: .center) {
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
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(imageNames, id: \.self) { imageName in
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width / 2.5)
                                .cornerRadius(10)
                                .clipped()
                        }
                    }
                    .padding(.horizontal)
                }
                
                
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
                .padding(.vertical,8)
                
                Text("Ваш персональный Имам")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
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
                    isChatOpen = true
                }) {
                    Text("Задайте вопрос Имаму!")
                        .font(.headline)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGray6))
                        .foregroundColor(Color.primary)
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
                Spacer()
                
            }
            .sheet(isPresented: $isChatOpen) {
                ChatScreen()
//                    .environmentObject(chatHelper)
                
            }
            .preferredColorScheme(.light)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        
    }
        
    
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
