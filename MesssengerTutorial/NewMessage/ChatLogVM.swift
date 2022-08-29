//
//  ChatLogVM.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/29/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class ChatLogVM: ObservableObject {
    @ObservedObject var mainVM: MainMessagesVM
    
    @Published var messageText: String = ""
    @Published var chatMessages = [ChatMessage]()
    
    var messageIsAnImage: Bool = false
    var imageURL: String = ""
    var messageImageURL: String?
    var chatUser: ChatUser?
    
    init(chatUser: ChatUser?, mainVM: MainMessagesVM) {
        self.chatUser = chatUser
        self.mainVM = mainVM
        fetchMessages()
    }
    
    var firestoreListener: ListenerRegistration?
    var firebaseDeleteListener: ListenerRegistration?
    
    func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        firestoreListener = FirebaseManager.shared.firestore
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
            
        persistRecentMessage()
        
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
    
    func handleImageSend(url: String) {
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let chatUser = chatUser else { return }
            
        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(chatUser.uid)
            .document()

        let imageMessageData = ["fromId": fromId, "toId": chatUser.uid, "text": url, "timestamp": Timestamp()] as [String : Any]
        
        if !imageMessageData.isEmpty {
            messageIsAnImage.toggle()
        }
        
        document.setData(imageMessageData) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
        
        persistRecentMessage()
        
        let recipientDocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(chatUser.uid)
            .collection(fromId)
            .document()
        
        recipientDocument.setData(imageMessageData) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    func persistRecentMessage() {
        
        guard let chatUser = chatUser else { return }
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let currentUser = FirebaseManager.shared.currentUser else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .document(chatUser.uid)
        
        let data = [
            "timestamp": Timestamp(),
            "text": messageIsAnImage && chatUser.username != currentUser.username ? "You sent an image" : self.messageText,
            "fromId": uid,
            "toId": chatUser.uid,
            "profileImageUrl": chatUser.profileImageUrl,
            "username": chatUser.username
        ] as [String: Any]
        
        document.setData(data) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
        
        let recipientRecentMessage = [
            "timestamp": Timestamp(),
            "text": messageIsAnImage ? "\(currentUser.username) sent an image" : self.messageText,
            "fromId": uid,
            "toId": chatUser.uid,
            "profileImageUrl": currentUser.profileImageUrl,
            "username": currentUser.username
        ] as [String: Any]
        
        FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(chatUser.uid)
            .collection("messages")
            .document(currentUser.uid)
            .setData(recipientRecentMessage) { error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
    }
    
    func deleteChatLog() {
        guard let toId = chatUser?.uid else { return }
        guard let currentUser = FirebaseManager.shared.currentUser else { return }
        
        firebaseDeleteListener?.remove()
        
        firebaseDeleteListener = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(currentUser.uid)
            .collection("messages")
            .document(toId)
            .addSnapshotListener { snapshot, error in
                guard let document = snapshot else { return }
                
                if let index = self.mainVM.recentMessages.firstIndex(where: { message in
                    return message.documentId == document.reference.documentID
                }) {
                    self.mainVM.recentMessages.remove(at: index)
                    document.reference.delete()
                }
            }
        
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(currentUser.uid)
            .collection(toId)
            .getDocuments { snapshot, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                } else {
                    for doc in snapshot!.documents {
                        doc.reference.delete()
                    }
                }
            }
        
        let path = currentUser.uid + "/" + toId
        FirebaseManager.shared.storage
            .reference()
            .child(path)
            .listAll(completion: { result, _ in
                guard let result = result else { return }
                    for item in result.items {
                        item.delete { error in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                print("DEBUG: Sucessfully deleted")
                            }
                        }
                    
                }
            })
    }
}
