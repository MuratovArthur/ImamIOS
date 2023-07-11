import SwiftUI
import Combine
import UIKit

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

struct ChatScreen: View {
    @State private var isTyping: Bool = false
    @State var chatMessages: [ChatMessage] = ChatMessage.sampleMessages
    @State var messageText: String = ""
    @State var cancellables = Set<AnyCancellable>()
    @State var listCount: Int = 0
    @State var scrollToBottom: Bool = false
    @State var textViewValue = String()
    @State var textViewHeight: CGFloat = 50.0
    @State private var editorHeight: CGFloat = 40
    @State private var text = "Testing text"
    @State private var isMenuOpen = false
    private var maxHeight: CGFloat = 250
    @State private var isEditing: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedTab: ContentView.Tab
    
    internal init(selectedTab: Binding<ContentView.Tab>) {
        _selectedTab = selectedTab
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    customNavBar.padding(geometry.safeAreaInsets.top)
                    ScrollViewReader { scrollViewProxy in
                        ScrollView(showsIndicators: false) {
                            VStack {
                                ForEach(chatMessages, id: \.id) { message in
                                    messageView(message: message)
                                        .id(message.id)
                                        .font(.system(size: 17))
                                }
                                .onChange(of: chatMessages.count) { _ in
                                    if scrollToBottom {
                                        scrollToLastMessage(scrollViewProxy: scrollViewProxy)
                                    }
                                }
                            }
                        }
                        .onAppear {
                            scrollToLastMessage(scrollViewProxy: scrollViewProxy)
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                            scrollToBottom = true
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                            scrollToBottom = false
                        }
                    }
                    .onTapGesture {
                        hideKeyboard()
                    }
                    
                    if isTyping {
                        withAnimation(.easeInOut) {
                            HStack {
                                Text("Имам печатает...")
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    
                    HStack {
                        ResizableTextView(text: $textViewValue, height: $textViewHeight, placeholderText: "Type a message")
                            .frame(height: textViewHeight < 160 ? self.textViewHeight : 160)
                            .cornerRadius(16)
                        
                        Button(action: {
                            sendMessage()
                        }) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 20))
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom) // Add bottom padding to the HStack
                    
                }
                
            }
            
            .padding(.horizontal)
            .toolbar {
                ToolbarItemGroup { }
            }
        }
    }
    
    var backButton: some View {
        Button(action: {
            selectedTab = .home
        }) {
            Image(systemName: "chevron.left")
                .font(.title)
                .foregroundColor(.black)
                .imageScale(.medium)
        }
    }
    
    var customNavBar: some View {
        HStack {
            backButton
            
            Spacer()
            
            avatarTitle
            
            Spacer()
            
            // Add other elements for your navigation bar here...
        }
        .padding()
        // Use this for side padding or adjust as needed.
        .background(Color.white) // Change this to the desired background color of your nav bar.
        //            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1) // Optional shadow for a bit of depth.
        .navigationBarHidden(true) // Hide the default navigation bar
    }
    
    
    var avatarTitle: some View {
        HStack {
            Image("imam")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 3)
            
            VStack(alignment: .leading) {
                Text("Имам")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("last seen recently")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 10)
            
            Spacer()
        }
    }
    
    func messageView(message: ChatMessage) -> some View {
        HStack {
            if message.sender == .user { Spacer() }
            
            Text(message.content)
                .foregroundColor(message.sender == .user ? .white : .black)
                .padding()
                .background(message.sender == .user ? Color.blue : Color.gray.opacity(0.1))
                .cornerRadius(16)
            
            if message.sender == .gpt { Spacer() }
        }
    }
    
    func fetchConversationID(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://fastapi-s53t.onrender.com/messages/") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            if let conversationID = String(data: data, encoding: .utf8) {
                completion(conversationID)
            } else {
                print("Failed to convert data to string")
                completion(nil)
            }
        }.resume()
    }
    
    
    
    
    func sendMessage() {
        let trimmedMessage = textViewValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedMessage.isEmpty {
            let myMessage = ChatMessage(id: UUID().uuidString, content: trimmedMessage, dataCreated: Date(), sender: .user)
            chatMessages.append(myMessage)
            textViewValue = "" // Clear the input text view
            
            // Show typing animation
            isTyping = true
            
            fetchConversationID { conversationID in
                if let id_conv = conversationID?.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "") {
                    print(id_conv)
                    
                    let question = trimmedMessage
                    let requestData: [String: Any] = ["question": question]
                    
                    guard let baseURL = URL(string: "https://fastapi-s53t.onrender.com/messages/") else {
                        print("Invalid base URL")
                        return
                    }
                    
                    let url = baseURL.appendingPathComponent(id_conv)
                    print(url.absoluteString)
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue("application/json", forHTTPHeaderField: "Accept")
                    
                    do {
                        let requestData = try JSONSerialization.data(withJSONObject: requestData, options: [])
                        request.httpBody = requestData
                    } catch {
                        print("Error encoding JSON: \(error)")
                        return
                    }
                    
                    URLSession.shared.dataTask(with: request) { data, response, error in
                        if let error = error {
                            print("Error: \(error)")
                            return
                        }
                        
                        guard let data = data else {
                            print("No data received")
                            return
                        }
                        
                        if let responseString = String(data: data, encoding: .utf8) {
                            // Remove quotes from the response string
                            let cleanedResponseString = responseString.replacingOccurrences(of: "\"", with: "")
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                // Hide typing animation and display bot message
                                isTyping = false
                                let botMessage = ChatMessage(id: UUID().uuidString, content: cleanedResponseString, dataCreated: Date(), sender: .gpt)
                                chatMessages.append(botMessage)
                            }
                        } else {
                            print("Failed to convert response data to string")
                        }
                    }.resume()
                } else {
                    print("oooooops...")
                }
            }
        }
    }
    
    
    
    
    
    
    func scrollToLastMessage(scrollViewProxy: ScrollViewProxy) {
        withAnimation {
            scrollViewProxy.scrollTo(chatMessages.last?.id, anchor: .bottom)
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

//struct ChatScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatScreen()
//    }
//}



struct ChatMessage {
    let id: String
    let content: String
    let dataCreated: Date
    let sender: MessageSender
}

enum MessageSender {
    case user
    case gpt
}

extension ChatMessage {
    
    static let sampleMessages = [
        ChatMessage(id: UUID().uuidString, content: "Ассаламу Алейкум! Как я могу вам помочь?", dataCreated: Date(), sender: .gpt)
    ]
}
