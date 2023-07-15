//
//  CalendarButtonView.swift
//  ImamAI
//
//  Created by Muratov Arthur on 15.07.2023.
//

import SwiftUI

struct CalendarButtonView: View {
    let currentDate: Date
    let isEventListVisible: Binding<Bool>
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        Button(action: {
            isEventListVisible.wrappedValue.toggle()
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
    }
}

//struct CalendarButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        CalendarButtonView()
//    }
//}
