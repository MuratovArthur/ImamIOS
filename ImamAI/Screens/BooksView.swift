//
//  BooksView.swift
//  ImamAI
//
//  Created by Nurali Rakhay on 02.08.2023.
//

import SwiftUI

struct BooksView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let data = [Book(title: "Some Title", coverImage: "image1"),
                Book(title: "Some Title2", coverImage: "image2"),
                Book(title: "Some Title3", coverImage: "image3")]
    
    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.black)
        }
    }
    
    var body: some View {
        NavigationView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 10) {
                ForEach(data, id: \.self) { item in
                    NavigationLink {
                        CompassView()
                    } label: {
                        BookCoverView(bookTitle: item.title, imageName: item.coverImage)
                    }
                }
            }
            .padding(10)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
}

struct BookCoverView: View {
    let bookTitle: String
    let imageName: String
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150) // Adjust the height as needed
            
            Text(bookTitle)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct Book: Hashable {
    let title: String
    let coverImage: String
}

struct BooksView_Previews: PreviewProvider {
    static var previews: some View {
        BooksView()
    }
}
