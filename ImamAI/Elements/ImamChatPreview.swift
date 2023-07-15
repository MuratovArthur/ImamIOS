//
//  ImamChat.swift
//  ImamAI
//
//  Created by Muratov Arthur on 15.07.2023.
//

import SwiftUI

struct ImamChatPreview: View {
    @Binding var selectedTab: ContentView.Tab
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Персональный Имам")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
                
            HStack {
                
                Image("imam-love")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width / 2.7)
                    .cornerRadius(10)
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Добро пожаловать ко мне, вашему персональному Имаму! Не стесняйтесь задавать волнующие вопросы прямо сейчас и вместе мы погрузимся в мир исламской культуры.")
                        .font(.subheadline)
                }
                
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal)
            
            Button(action: {
                selectedTab = .other
            }) {
                Text("Задайте свой вопрос!")
                    .font(.headline)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.black))
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
            }
        }
        .multilineTextAlignment(.leading)
    }
}

struct ImamChatPreview_Previews: PreviewProvider {
    static var previews: some View {
        ImamChatPreview(selectedTab: .constant(.other))
    }
}
