//
//  LocationSwitchView.swift
//  ImamAI
//
//  Created by Nurali Rakhay on 18.08.2023.
//

import SwiftUI

struct LocationSwitchView: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "location")
                    .font(.title)
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Astana")
                        .font(.headline)
                    Text("Kazakhstan")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            HStack {
                Text("A new nearest location is found")
                    .font(.body)
                Spacer()
            }
            
            Button(action: {
                // Action for switching location
            }) {
                Text("SWITCH TO LOCATION")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
            }
            
            Button(action: {
                // Action for closing
            }) {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)

    }
}

struct LocationSwitchView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSwitchView()
    }
}
