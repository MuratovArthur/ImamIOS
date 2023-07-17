//
//  ImamNavBarView.swift
//  ImamAI
//
//  Created by Muratov Arthur on 17.07.2023.
//

import SwiftUI

struct ImamNavBarView: View {
    var body: some View {
        HStack {
            
            avatarTitle
            
            Spacer()
            
            // Add other elements for your navigation bar here...
        }
        .padding(.horizontal)
        // Use this for side padding or adjust as needed.
        .background(Color.white) // Change this to the desired background color of your nav bar.
        //            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1) // Optional shadow for a bit of depth.
        .navigationBarHidden(true) // Hide the default navigation bar
    }
}

struct ImamNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        ImamNavBarView()
    }
}

var avatarTitle: some View {
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
            Text("last seen recently")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.leading, 10)
        
        Spacer()
    }
    .padding(.top)
}
