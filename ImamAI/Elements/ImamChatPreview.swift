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
            Text(NSLocalizedString("personal-imam", comment: "chat preview"))
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
                    Text(NSLocalizedString("imam-text", comment: "chat preview"))
                        .font(.subheadline)
                }
                
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal)
            
            Button(action: {
                selectedTab = .other
            }) {
                Text(NSLocalizedString("ask-question", comment: "chat preview"))
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
