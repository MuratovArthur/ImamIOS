//
//  LoadingView.swift
//  ImamAI
//
//  Created by Muratov Arthur on 15.07.2023.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            Image("imam")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200)
 
            
            Text("Ассаламу Алейкум!")
                .font(.title)
                .fontWeight(.bold)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
