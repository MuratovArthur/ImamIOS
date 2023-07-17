import Foundation
import Combine

class ChatViewModel: ObservableObject {
    static let shared = ChatViewModel()
    @Published var chatMessages: [ChatMessage] = ChatMessage.sampleMessages
    @Published var textViewValue: String = ""
    @Published var isTyping = false
    
    private var conversationID: String?
    
    func sendMessage() {
        let trimmedMessage = self.textViewValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else {
            return
        }
        
        // Show typing animation
        self.isTyping = true

        print("isTyping is now \(self.isTyping)") // debug print

        if let conversationID = conversationID {
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
        self.textViewValue = "" // Clear the input text view
    }
    
    
    
    func sendMessageToConversation(conversationID: String, message: String) {
        print("sending message")
        
        let conversationIDWithoutQuotes = conversationID.replacingOccurrences(of: "\"", with: "")
        let conversationURL = "https://fastapi-s53t.onrender.com/messages/\(conversationIDWithoutQuotes)"
        guard let url = URL(string: conversationURL) else {
            print("Invalid URL")
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
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                    let correctedString = responseString.replacingOccurrences(of: "\\n", with: "\n").replacingOccurrences(of: "\\\"", with: "\"").trimQuotes()
                    
                    // Create a new ChatMessage object and append it to chatMessages
                    let receivedMessage = ChatMessage(id: UUID().uuidString, content: correctedString, dataCreated: Date(), sender: .gpt)
                    DispatchQueue.main.async {
                        self?.chatMessages.append(receivedMessage)
                    }
                } else {
                    print("Failed to convert response data to string")
                }
                
                DispatchQueue.main.async {
                           self?.isTyping = false // Stop typing animation
                    print("isTyping is now \(String(describing: self?.isTyping))") // debug print
                       }
            }.resume()
            
        } catch {
            print("Error encoding JSON: \(error)")
        }
    }
    
    
    func createNewConversation(completion: @escaping (String?) -> Void) {
        print("creating new conversation")
        
        guard let url = URL(string: "https://fastapi-s53t.onrender.com/messages/") else {
            print("Invalid URL 1")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                self?.isTyping = false
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                self?.isTyping = false
                return
            }
            
            if let conversationID = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                print("conversationID: ", conversationID)
                completion(conversationID)
            } else {
                print("Invalid response")
                completion(nil)
            }
            
            print("finished creating new conversation")
     
            
        }.resume()
    }
    
    func showError() {
        print("Error")
    }
}
