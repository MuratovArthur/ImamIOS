//
//  PostsView.swift
//  ImamAI
//
//  Created by Muratov Arthur on 11.07.2023.
//
import SwiftUI
import SDWebImageSwiftUI

struct PostsView: View {
    // Properties
    @State private var posts: [Post] = []
    @State private var offset: Int = 0
    @State private var totalPosts: Int = 0
    @State private var selectedPost: Post?
    @State private var allPostsLoaded = false
    @State private var postAreLoading = false
    @Binding var tabBarShouldBeHidden: Bool
    @EnvironmentObject private var globalData: GlobalData
    let maxDescriptionLength = 50
    let postHeight: CGFloat = 130
    
    var body: some View {
        
        VStack(alignment: .leading){
            Text("to-read", bundle: globalData.bundle)
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top)
            
            if postAreLoading == false {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(posts) { post in
                            NavigationLink(destination: PostDetailView(post: post, tabBarShouldBeHidden: $tabBarShouldBeHidden)) {
                                HStack(spacing: 8) {
                                    WebImage(url: URL(string: post.imageName))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: 170, maxHeight: 200)
                                        .cornerRadius(10)
                                        .clipped()
                                    
                                    
                                    
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text(post.title)
                                            .font(.headline)
                                            .foregroundColor(Color.black)
                                        
                                        Text(post.description)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                }
                                .frame(height: postHeight)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                                .clipped()
                                .padding(.horizontal)
                            }
                        }
                        if allPostsLoaded {
                            Text("all-posts-loaded", bundle: globalData.bundle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.top, 5)
                        } else {
                            HStack {
                                Spacer()
                                Button(action: {
                                    print("click on button")
                                    if self.posts.count < self.totalPosts {
                                        self.offset += 3
                                        loadPosts()
                                    } else {
                                        allPostsLoaded = true
                                    }
                                    
                                }) {
                                    Text("load-more", bundle: globalData.bundle)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .padding()
                                        .background(Color(UIColor.systemGray6))
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal)
                                
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .onAppear {
                    if self.posts.isEmpty {
                        loadPosts()
                    }
                }
                .onChange(of: globalData.locale) { newValue in
                    self.posts.removeAll()
                    self.allPostsLoaded = false
                    self.offset = 0
                    loadPosts()
                }
            }else{
                ProgressView()
            }
        }
    }
    
    // This method should be here
    private func loadPosts() {
        postAreLoading = true
        print("loadPosts() called") // Check if this function is being called
        
        let urlString = "https://railway-imamai-production.up.railway.app/posts/get_posts/\(globalData.locale)?limit=3&offset=\(offset)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            postAreLoading = false
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("Received response from server") // Check if the server response is received
            
            if let data = data {
                print("Received data from server:", data)
                //                    if let responseString = String(data: data, encoding: .utf8) {
                //                        print("Server Response: \(responseString)")
                //                    } else {
                //                        print("Could not decode server response to String")
                //                    }
                do {
                    let decodedResponse = try JSONDecoder().decode(PostServerResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.posts += decodedResponse.objects.map { Post(postObject: $0) }
                        self.totalPosts = decodedResponse.total
                    }
                } catch let decodingError {
                    print("Decoding error:", decodingError)
                    postAreLoading = false
                }

            } else if let error = error {
                print("Error: \(error.localizedDescription)")
                postAreLoading = false
            }
        }.resume()
        postAreLoading = false
    }
    
    
}


struct PostDetailView: View {
    let post: Post
    @Binding var tabBarShouldBeHidden: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(showsIndicators: false) {
                
//                AsyncImage(
//                    url: URL(string: post.imageName),
//                    content: { image in
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(maxWidth: .infinity, maxHeight: 200)
//                            .cornerRadius(10)
//                            .clipped()
//                    },
//                    placeholder: {
//                        ProgressView()
//                            .padding()
//                    }
//                )
//                .padding(.vertical, 16)
                

                WebImage(url: URL(string: post.imageName))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .cornerRadius(10)
                    .clipped()
////                    .placeholder(ProgressView().padding())
////                    .padding(.vertical, 16)

                
                VStack(alignment: .leading) {
                    
                    Text(post.description)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                    
                }
                

                .navigationBarHidden(true)
                
//                .padding(.top)
            }
//            .padding(.vertical)
            .navigationBarHidden(true)
            .padding(.bottom, 8)
            
            
//            Spacer()
        }
        .padding(.horizontal)
        .multilineTextAlignment(.leading)
        .navigationTitle(Text(post.title))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(false)
        .onAppear(){
            tabBarShouldBeHidden = true
        }
        .onDisappear(){
            tabBarShouldBeHidden = false
        }
    }
    
    
    private func splitIntoParagraphs(_ text: String) -> [String] {
        return text.components(separatedBy: "\n")
    }
}


//struct PostsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostsView(posts: posts)
//    }
//}
//
//
//
//

//struct PostsView_Preview_Detailed: PreviewProvider {
//    static var previews: some View {
//        PostDetailView(post:posts[0])
//    }
//}

struct PostServerResponse: Codable {
    var total: Int
    var objects: [PostObject]
}

struct PostObject: Codable, Identifiable {
    var id: String
    var title: String
    var imageURL: String
    var description: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case imageURL
        case description
    }
}


struct Post: Identifiable {
    let id: UUID
    let title: String
    let imageName: String
    let description: String
    
    init(postObject: PostObject) {
        id = UUID()
        title = postObject.title
        imageName = postObject.imageURL
        description = postObject.description
    }
}
