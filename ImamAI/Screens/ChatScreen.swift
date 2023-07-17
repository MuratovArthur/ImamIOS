import SwiftUI
import Combine
import UIKit
import Foundation

struct ChatScreen: View {
    @ObservedObject private var viewModel = ChatViewModel.shared
    @State var messageText: String = ""
    @State var scrollToBottom: Bool = false
    @State var textViewValue = String()
    @State var textViewHeight: CGFloat = 10.0
    @Binding var selectedTab: ContentView.Tab
    @State private var isTyping = false
    
    internal init(viewModel: ChatViewModel, selectedTab: Binding<ContentView.Tab>) {
        self.viewModel = viewModel
        _selectedTab = selectedTab
        _isTyping = State(initialValue: viewModel.isTyping)
    }
    
    var body: some View {
            GeometryReader { geometry in
                VStack {
                    ImamNavBarView()
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
                        .onAppear {
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
            }
    }
    
    
    
    func messageView(message: ChatMessage) -> some View {
        print("message content: ", message.content)

        return HStack {
            if message.sender == .user { Spacer() }

            VStack(alignment: .leading, spacing: 8) {
                let lines = splitLines(message.content)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(lines.indices, id: \.self) { lineIndex in
                        let line = lines[lineIndex]
                        let text = line.isEmpty ? " " : line
                        Text(text)
                            .foregroundColor(message.sender == .user ? .white : .black)
                    }
                }
                .padding()
                .background(message.sender == .user ? Color.blue : Color.gray.opacity(0.1))
                .cornerRadius(16)
            }

            if message.sender == .gpt { Spacer() }
        }
    }

    func splitLines(_ content: String) -> [String] {
        var lines = content.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        // Convert empty strings to strings with a space to represent empty lines
        for i in 0..<lines.count {
            if lines[i].isEmpty {
                lines[i] = " "
            }
        }
        return lines
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

extension String {
    func trimQuotes() -> String {
        var trimmedString = self
        if trimmedString.first == "\"" {
            trimmedString.removeFirst()
        }
        if trimmedString.last == "\"" {
            trimmedString.removeLast()
        }
        return trimmedString
    }
}
