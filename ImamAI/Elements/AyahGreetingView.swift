//
//  AyahGreetingView.swift
//  ImamAI
//
//  Created by Muratov Arthur on 15.07.2023.
//

import SwiftUI

struct AyahGreetingView: View {
    var body: some View {
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
    }
}

struct AyahGreetingView_Previews: PreviewProvider {
    static var previews: some View {
        AyahGreetingView()
    }
}
