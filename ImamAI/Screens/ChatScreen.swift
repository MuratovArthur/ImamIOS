import SwiftUI
import Combine
import UIKit
import Foundation

struct ChatScreen: View {
    @ObservedObject private var viewModel = ChatViewModel.shared
    @ObservedObject var networkMonitor = NetworkMonitor()
    @EnvironmentObject private var globalData: GlobalData
    @State var messageText: String = ""
    @State var scrollToBottom: Bool = true
    @State var textViewValue = String()
    @State var textViewHeight: CGFloat = 10.0
    @Binding var selectedTab: ContentView.Tab
    @State private var isTyping = false
    
    @State private var sentOneMessage = false
    @State private var showAlert = false
    
    internal init(viewModel: ChatViewModel, selectedTab: Binding<ContentView.Tab>) {
        self.viewModel = viewModel
        _selectedTab = selectedTab
        _isTyping = State(initialValue: viewModel.isTyping)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ImamNavBarView(sentOneMessage: $sentOneMessage, showAlert: $showAlert)
                
                if viewModel.errorMessage == ""
                {
                    ScrollViewReader { scrollViewProxy in
                        if !viewModel.fetchingMessages {
                            ScrollView(showsIndicators: false) {
                                VStack {
                                    ForEach(viewModel.chatMessages, id: \.id) { message in
                                        messageView(message: message)
                                            .id(message.id)
                                            .font(.system(size: 17))
                                    }
                                    .onAppear {
                                        scrollToLastMessage(scrollViewProxy: scrollViewProxy)
                                    }
                                    .onChange(of: viewModel.chatMessages.count) { _ in
                                        if scrollToBottom {
                                            scrollToLastMessage(scrollViewProxy: scrollViewProxy)
                                        }
                                    }
                                    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            withAnimation {
                                                scrollToBottom = true
                                                if let lastMessageID = viewModel.chatMessages.last?.id {
                                                    scrollViewProxy.scrollTo(lastMessageID, anchor: .bottom)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .onAppear {
                                scrollToBottom = true
                            }
                            
                            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        scrollToBottom = true
                                        if let lastMessageID = viewModel.chatMessages.last?.id {
                                            scrollViewProxy.scrollTo(lastMessageID, anchor: .bottom)
                                        }
                                    }
//                                }
                            }
                            .onChange(of: textViewHeight) { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation {
                                        if let lastMessageID = viewModel.chatMessages.last?.id {
                                            scrollViewProxy.scrollTo(lastMessageID, anchor: .bottom)
                                        }
                                    }
                                }
                            }
                        }else{
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    }
                    .onTapGesture {
                        hideKeyboard()
                    }
                    
                } else {
                    Text(viewModel.errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                }
                
                
                if isTyping {
                        HStack {
                            TypingAnimationView()
                            Spacer() // Add spacer to align to the left
                        }
                        .padding(.leading, 8)
                }
                
                
                if networkMonitor.isConnected {
                    HStack {
                        ResizableTextView(text: $textViewValue, height: $textViewHeight, placeholderText: NSLocalizedString("placeholder", bundle: globalData.bundle ?? Bundle.main, comment: "chat screen"))
                            .frame(height: textViewHeight < 160 ? self.textViewHeight : 160)
                            .cornerRadius(16)
                        
                        Button(action: {
                            viewModel.textViewValue = textViewValue
                            viewModel.sendMessage()
                            textViewValue = "" // Clear the local textViewValue
                            sentOneMessage = true
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
                else{
                    Text("no-internet", bundle: globalData.bundle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.vertical)
                }
            }
            .onAppear {
                scrollToBottom = true
            }
            .padding(.horizontal)
            .onReceive(viewModel.$isTyping) { typing in
                self.isTyping = typing
            }
            .onAppear {
                if viewModel.conversationID == nil {
                    viewModel.createNewConversation { conversationID in
                        if conversationID != nil {
                            viewModel.fetchChatMessages()
                            scrollToBottom = true
                        } else {
                            print("Failed to create a new conversation")
                        }
                    }
                } else {
                    viewModel.fetchChatMessages()
                    scrollToBottom = true
                }
            }
            .alert(isPresented: $showAlert, content: {
                Alert(
                    title: Text("delete-chat", bundle: globalData.bundle),
                    message: Text("delete-question", bundle: globalData.bundle),
                    primaryButton: .destructive(Text("delete", bundle: globalData.bundle)) {
                        if viewModel.chatMessages.count > 1{
                            viewModel.clearHistory()
                            print("Updated")
                        }
                    },
                    secondaryButton: .cancel(Text("cancel", bundle: globalData.bundle))
                )
            })
        }
    }
    
    
    
    func messageView(message: ChatMessage) -> some View {
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
