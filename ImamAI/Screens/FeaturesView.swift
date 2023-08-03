//
//  FeaturesView.swift
//  ImamAI
//
//  Created by Nurali Rakhay on 02.08.2023.
//

import SwiftUI

struct FeaturesView: View {
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 10), count: 2)
    let sampleData = (1...10).map { "View \($0)" }
    
    var body: some View {
        NavigationView {
            VStack (alignment: .leading) {
                Text("Useful")
                    .font(.title)
                    .fontWeight(.bold)
                VStack {
                    NavigationLink {
                        CompassView()
                    } label: {
                        FeatureContainerView(imageName: "safari", title: NSLocalizedString("qibla-search", comment: "compass-view"))
                    }
                    
                    NavigationLink {
                        BooksView()
                    } label: {
                        FeatureContainerView(imageName: "book", title: "Books")
                    }
                }
                Spacer()
            }
            .padding()
        }
        
    }
}

struct FeatureContainerView: View {
    let imageName: String
    let title: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(.systemGray6)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: imageName) // Replace this
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.black)
                
                Text(title)
                    .font(.title2)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
            }
            .padding(16) // Adjust the padding to your preference
        }
        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height / 4)
    }
}


struct FeaturesView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturesView()
    }
}
