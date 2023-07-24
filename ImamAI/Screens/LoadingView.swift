//
//  LoadingView.swift
//  ImamAI
//
//  Created by Muratov Arthur on 15.07.2023.
//

import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @Binding var errorText: String
    
    var body: some View {
        VStack {
            
            Image("imam")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200)
            
            Text("Ассаламу Алейкум!")
                .font(.title)
                .fontWeight(.bold)
            
            
            
            if !errorText.isEmpty {
                Text(errorText)
                    .foregroundColor(.red)
                    .padding(.top)
            } else if !networkMonitor.isConnected {
                Text("Отсутствует подключение к интернету")
                    .foregroundColor(.red)
                    .padding(.top)
            } else {
                ProgressView()
                    .padding(.vertical)
            }
            
            Text("При первом запуске загрузка может занять больше времени")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 5)
        }
    }
}


//struct LoadingView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoadingView()
//    }
//}
