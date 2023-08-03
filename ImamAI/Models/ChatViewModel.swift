import Foundation
import Combine

struct ServerMessage: Decodable {
    let role: String
    let content: String
}

class ChatViewModel: ObservableObject {
    static let shared = ChatViewModel()
    @Published var chatMessages: [ChatMessage] = []{
        didSet {
            print("Chat messages updated. New count: \(chatMessages.count)")
        }
    }
    @Published var textViewValue: String = ""
    @Published var isTyping = false
    @Published var errorMessage: String = ""
    @Published var fetchingMessages = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var conversationID: String? {
        didSet {
            UserDefaultsManager.shared.saveConversationID(conversationID ?? "")
            fetchChatMessages()
        }
    }
    
    init() {
        if let storedID = UserDefaultsManager.shared.getConversationID() {
            self.conversationID = storedID.replacingOccurrences(of: "\"", with: "")
        }
    }
    
    func clearHistory() {
        // Create new conversation
        createNewConversation { [weak self] conversationID in
            guard let conversationID = conversationID else {
                print("Failed to create a new conversation.")
                self?.showError()
                return
            }
            // Update the value of conversationID in user defaults
            UserDefaultsManager.shared.saveConversationID(conversationID)
            // Clear chatMessages
            self?.chatMessages = []
            // Fetch new messages
            self?.fetchChatMessages()
            print("History cleared and new conversation created.")
        }
    }

    
    func fetchChatMessages() {
        self.fetchingMessages = true
        print("Stored conversationID: \(String(describing: conversationID))")
        
        guard let conversationID = conversationID else {
            print("conversationID is nil")
            self.fetchingMessages = false
            self.showError()
            return
        }
        
        let urlString = "https://fastapi-s53t.onrender.com/messages/\(conversationID)"
        print("Constructed URL string: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Failed to create URL from string: \(urlString)")
            self.fetchingMessages = false
            self.showError()
            return
        }
        
        print("Fetching messages for conversationID: \(conversationID)")
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [ServerMessage].self, decoder: JSONDecoder())
            .map { serverMessages in
                print("Received \(serverMessages.count) server messages")
                return serverMessages.map { serverMessage in
                    print("Converting server message with content: \(serverMessage.content) and role: \(serverMessage.role)")
                    return ChatMessage(id: UUID().uuidString,
                                       content: serverMessage.content,
                                       dataCreated: Date(),
                                       sender: serverMessage.role == "assistant" ? .gpt : .user)
                }
            }
            .replaceError(with: [ChatMessage]()) // Corrected here, replacing error with empty ChatMessage array
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Failed with error: \(error)")
                    self.showError()
                case .finished:
                    print("Finished successfully")
                }
                self.fetchingMessages = false // make sure to set this here
            }, receiveValue: { chatMessages in
                print("Received \(chatMessages.count) chat messages")
                self.chatMessages = chatMessages
                print("Fetching messages, number of messages fetched: \(self.chatMessages.count)")
            })
            .store(in: &cancellables)

        
        print("Fetching messages, number of messages fetched: \(self.chatMessages.count)")
    }
    
    
    func sendMessage() {
        self.errorMessage = ""
        let trimmedMessage = self.textViewValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else {
            return
        }
        
        self.isTyping = true
        
        if let conversationID = conversationID {
            print(conversationID)
            sendMessageToConversation(conversationID: conversationID, message: trimmedMessage)
        } else {
            createNewConversation { [weak self] conversationID in
                guard let conversationID = conversationID else {
                    self?.showError()
                    return
                }
                
                self?.conversationID = conversationID // Store the conversation ID
                self?.sendMessageToConversation(conversationID: conversationID, message: trimmedMessage)
            }
        }
        
        let myMessage = ChatMessage(id: UUID().uuidString, content: trimmedMessage, dataCreated: Date(), sender: .user)
        self.chatMessages.append(myMessage)
        print("Message sent, total number of messages now: \(self.chatMessages.count)")
    }
    
    
    func sendMessageWhenNoInternet() {
        let trimmedMessage = self.textViewValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else {
            print("Error: Message cannot be empty or whitespace.")
            return
        }
        
        // Show typing animation
//        self.isTyping = true
        
//        print("isTyping is now \(self.isTyping)") // debug print
        
        let receivedMessage = ChatMessage(id: UUID().uuidString, content: "Ассаламу Алейкум! Я чуть-чуть занят сейчас, напиши мне попозже.", dataCreated: Date(), sender: .gpt)
        
        chatMessages.append(receivedMessage)
        
        let myMessage = ChatMessage(id: UUID().uuidString, content: trimmedMessage, dataCreated: Date(), sender: .user)
        self.chatMessages.append(myMessage)
    }
    
    
    func sendMessageToConversation(conversationID: String, message: String) {
        print("sending message")
        
        let conversationIDWithoutQuotes = conversationID.replacingOccurrences(of: "\"", with: "")
        let conversationURL = "https://fastapi-s53t.onrender.com/messages/\(conversationIDWithoutQuotes)"
        guard let url = URL(string: conversationURL) else {
            self.showError()
            return
        }
        
        let requestData: [String: Any] = ["question": message]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let requestData = try JSONSerialization.data(withJSONObject: requestData, options: [])
            request.httpBody = requestData
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                if error != nil {
                    self?.showError()
                    self?.isTyping = false
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.showError()
                    return
                }
                
                if httpResponse.statusCode != 200 {
                    let correctedString = "Ассаламу Алейкум! Я чуть-чуть занят сейчас, напиши мне попозже."
                    let receivedMessage = ChatMessage(id: UUID().uuidString, content: correctedString, dataCreated: Date(), sender: .gpt)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self?.chatMessages.append(receivedMessage)
                        self?.isTyping = false // Stop typing animation
                    }
                    return
                }
                
                guard let data = data else {
                    self?.showError()
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                    
                    let correctedString = responseString.replacingOccurrences(of: "\\n", with: "\n").replacingOccurrences(of: "\\\"", with: "\"").trimQuotes()
                    // Create a new ChatMessage object and append it to chatMessages
                    let receivedMessage = ChatMessage(id: UUID().uuidString, content: correctedString, dataCreated: Date(), sender: .gpt)
                    DispatchQueue.main.async {
                        self?.chatMessages.append(receivedMessage)
                        self?.isTyping = false // Stop typing animation
                    }
                } else {
                    self?.showError()
                }
            }.resume()
            
        } catch {
            self.isTyping = false
            self.showError()
        }
    }
         
    
    
    func createNewConversation(completion: @escaping (String?) -> Void) {
        print("creating new conversation")
        self.fetchingMessages = true

        guard let url = URL(string: "https://fastapi-s53t.onrender.com/messages/") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                self?.isTyping = false

                // Handle timeout error
                if let error = error as? URLError, error.code == .timedOut {
                    self?.showError()
                }

                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(nil)
                self?.isTyping = false
                return
            }

            if httpResponse.statusCode != 200 {
                // Handle non-200 status codes (e.g., 404, 500, etc.)
                self?.showError()
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                self?.isTyping = false
                return
            }

            if let conversationID = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                self?.conversationID = conversationID.replacingOccurrences(of: "\"", with: "")
                print("conversationID: ", self?.conversationID ?? "")
                completion(conversationID)
            } else {
                print("Invalid response")
                completion(nil)
            }

            print("finished creating new conversation")
            self?.fetchingMessages = false
        }

        task.resume()
        print("New conversation created with id: \(self.conversationID ?? "nil"), number of messages: \(self.chatMessages.count)")
    }

    
    func showError() {
        print("Error is being shown")
        self.errorMessage = NSLocalizedString("no-internet-suggestion", comment: "errors")
    }
}
