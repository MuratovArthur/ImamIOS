//
//  PostsView.swift
//  ImamAI
//
//  Created by Muratov Arthur on 11.07.2023.
//
import SwiftUI

struct Post: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let description: String
}



struct PostsView: View {
    let maxDescriptionLength = 50
    let postHeight: CGFloat = 130
    let posts: [Post] // Add this line to receive the array of posts as a parameter
    
    // Add a new state variable to track the selected post
    @State private var selectedPost: Post?
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Для прочтения")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(posts) { post in
                        Button(action: {
                            selectedPost = post // Set the selected post when the button is tapped
                        }) {
                            HStack(spacing: 8) {
                                Image(post.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width / 3)
                                    .cornerRadius(10)
                                    .clipped()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(post.title)
                                        .font(.headline)
                                        .foregroundColor(Color.black)
                                    
                                    Text(post.description.prefix(maxDescriptionLength) + "...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                            }
                            .frame(height: postHeight)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding(.bottom)
            .sheet(item: $selectedPost) { post in // Present the PostDetailView as a sheet
                PostDetailView(post: post)
            }
        }
    }
}



struct PostDetailView: View {
    @State private var isChatSheetPresented = false
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(post.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: 200)
                .cornerRadius(10)
                .clipped()
            
            Text(post.title)
                .font(.title)
                .fontWeight(.bold)
            
            Text(post.description)
                .font(.body)
            
            Spacer()
            
            
            
            HStack {
                Spacer()
                Button(action: {
                    isChatSheetPresented = true
                }) {
                    Image("imam")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 3)
                        .frame(width: 50, height: 50)
                        .padding(.trailing)
            }
            }
//            .padding(.bottom, 16)
//            .padding(.trailing, 16)
        }
        .padding()
        .multilineTextAlignment(.leading)
        .sheet(isPresented: $isChatSheetPresented) {
            ChatScreen(selectedTab: .constant(.other))
        }
    }
}


   


struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostsView(posts: posts)
    }
}




struct PostsView_Preview_Detailed: PreviewProvider {
    static var previews: some View {
        PostDetailView(post:posts[1])
    }
}
