import SwiftUI
import Combine
import UIKit
import Foundation

//struct ViewHeightKey: PreferenceKey {
//    static var defaultValue: CGFloat { 0 }
//    static func reduce(value: inout Value, nextValue: () -> Value) {
//        value = value + nextValue()
//    }
//}


struct ChatScreen: View {
    @ObservedObject private var viewModel = ChatViewModel.shared
    @State var messageText: String = ""
    @State var cancellables = Set<AnyCancellable>()
    @State var listCount: Int = 0
    @State var scrollToBottom: Bool = false
    @State var textViewValue = String()
    @State var textViewHeight: CGFloat = 10.0
    @State private var editorHeight: CGFloat = 10
    @State private var text = "Testing text"
    @State private var isMenuOpen = false
    private var maxHeight: CGFloat = 250
    @State private var isEditing: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedTab: ContentView.Tab
    @State private var isTyping = false
    
    internal init(viewModel: ChatViewModel, selectedTab: Binding<ContentView.Tab>) {
        self.viewModel = viewModel
        _selectedTab = selectedTab
        _isTyping = State(initialValue: viewModel.isTyping)
    }
    
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    customNavBar
                    ScrollViewReader { scrollViewProxy in
                        ScrollView(showsIndicators: false) {
                            VStack {
                                ForEach(viewModel.chatMessages, id: \.id) { message in
                                    messageView(message: message)
                                        .id(message.id)
                                        .font(.system(size: 17))
                                }
                                .onChange(of: viewModel.chatMessages.count) { _ in
                                    if scrollToBottom {
                                        scrollToLastMessage(scrollViewProxy: scrollViewProxy)
                                    }
                                }
                            }
                        }
                        .onChange(of: viewModel.isTyping) { newValue in
                            print("isTyping changed to: \(newValue)")
                        }
                        .onAppear {
                            scrollToLastMessage(scrollViewProxy: scrollViewProxy)
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                            scrollToBottom = true
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                            guard let userInfo = notification.userInfo else { return }
                            guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                            
                            let keyboardHeight = keyboardFrame.height
                            
                            // Find the active window scene
                            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                                // Calculate the adjusted visible height
                                let tabBarHeight = windowScene.windows.first?.safeAreaInsets.bottom ?? 0
                                _ = UIScreen.main.bounds.height - keyboardHeight - tabBarHeight
                                
                                // Check if the last message is visible
                                if let lastMessageID = viewModel.chatMessages.last?.id {
                                    withAnimation {
                                        scrollViewProxy.scrollTo(lastMessageID, anchor: .center)
                                    }
                                }
                            }
                        }
                        
                    }
                    .onTapGesture {
                        hideKeyboard()
                    }
                    
                    
                    if isTyping {
                        withAnimation {
                                HStack {
                                    TypingAnimationView()
                                    Spacer() // Add spacer to align to the left
                                }
                                .padding(.horizontal)
                            }
                    }
                    
                    
                    
                    HStack {
                        ResizableTextView(text: $textViewValue, height: $textViewHeight, placeholderText: "Type a message")
                            .frame(height: textViewHeight < 160 ? self.textViewHeight : 160)
                            .cornerRadius(16)
                        
                        Button(action: {
                            viewModel.textViewValue = textViewValue
                            viewModel.sendMessage()
                            textViewValue = "" // Clear the local textViewValue
                        }) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 20))
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .clipShape(Circle())
                        }
                        
                    }
                }
                .padding(.horizontal)
                .onReceive(viewModel.$isTyping) { typing in
                    self.isTyping = typing
                }
            } // end of GeometryReader
        }
    }
    
    
    
    
    var customNavBar: some View {
        HStack {
            
            avatarTitle
            
            Spacer()
            
            // Add other elements for your navigation bar here...
        }
        .padding(.horizontal)
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
        .padding(.top)
    }
    
    func messageView(message: ChatMessage) -> some View {
        let paragraphs = message.content.components(separatedBy: "\n\n")
        
        return HStack {
            if message.sender == .user { Spacer() }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 8) {
                ForEach(paragraphs, id: \.self) { paragraph in
                    let lines = paragraph.components(separatedBy: "\n")
                    VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 4) {
                        ForEach(lines, id: \.self) { line in
                            Text(line)
                                .foregroundColor(message.sender == .user ? .white : .black)
                        }
                    }
                    .padding()
                    .background(message.sender == .user ? Color.blue : Color.gray.opacity(0.1))
                    .cornerRadius(16)
                }
            }
            
            if message.sender == .gpt { Spacer() }
        }
    }
    
    
    func scrollToLastMessage(scrollViewProxy: ScrollViewProxy) {
        withAnimation {
            scrollViewProxy.scrollTo(viewModel.chatMessages.last?.id, anchor: .bottom)
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct ChatScreen_Previews: PreviewProvider {
    static var previews: some View {
        ChatScreen(viewModel: ChatViewModel(), selectedTab: .constant(.home))
    }
}
