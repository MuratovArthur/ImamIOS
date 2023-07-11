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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(posts) { post in
                    NavigationLink(destination: PostDetailView(post: post)) {
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
    }
}


struct PostDetailView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(post.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: 200)
                .cornerRadius(10) // Apply corner radius to create rounded borders
                .clipped()
            
            Text(post.title)
                .multilineTextAlignment(.leading)
                .font(.title2)
//                .fontWeight(.bold)
                .padding(.vertical)
                .padding(.top, 16)
            
            Text(post.description)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .navigationBarTitle(Text(post.title), displayMode: .inline)
        .padding()
        .multilineTextAlignment(.leading)
    }
        
        
}
   





struct PostsView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailView(post:posts[1])
    }
}
