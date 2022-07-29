//
//  ChatLogVM.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/29/22.
//

import SwiftUI
import Firebase

class ChatLogVM: ObservableObject {
    
    @Published var messageText: String = ""
    @Published var chatMessages = [ChatMessage]()
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        fetchMessages()
    }
    
    func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                snapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        let docId = change.document.documentID
                        let chatMessage = ChatMessage(documentId: docId, data: data)
                        self.chatMessages.append(chatMessage)
                    }
                })
            }
    }
    
    func handleSend() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = ["fromId": fromId, "toId": toId, "text": self.messageText, "timestamp": Timestamp()] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
        
        let recipientDocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientDocument.setData(messageData) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
        
        messageText = ""
    }
}
