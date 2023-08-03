//
//  HomeHeaderView.swift
//  ImamAI
//
//  Created by Nurali Rakhay on 03.08.2023.
//

import SwiftUI

struct HomeHeaderView: View {
    let currentDate = Date()
    
    var body: some View {
        HStack {
            CalendarButtonView(currentDate: currentDate)
                .padding(.horizontal, 10)
            
            Spacer()
            
            Button {
            
            } label: {
                Image(systemName: "globe")
                    .foregroundColor(.black)
                    .font(.system(size: 25))
            }
            .padding(.horizontal, 14)
            

        }
    }
}

struct HomeHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HomeHeaderView()
    }
}
