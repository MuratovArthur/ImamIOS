//
//  BooksView.swift
//  ImamAI
//
//  Created by Nurali Rakhay on 02.08.2023.
//

import SwiftUI

struct BooksView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
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
       Text("hello")
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton)
    }
}

struct BooksView_Previews: PreviewProvider {
    static var previews: some View {
        BooksView()
    }
}
