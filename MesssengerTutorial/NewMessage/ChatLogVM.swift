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
    
    @Published var messageText: String = ""
    @Published var chatMessages = [ChatMessage]()
    @Published var imageURL: String?
    
    var chatUser: ChatUser?
    @ObservedObject var mainVM: MainMessagesVM
    
    init(chatUser: ChatUser?, mainVM: MainMessagesVM) {
        self.chatUser = chatUser
        self.mainVM = mainVM
        fetchMessages()
    }
    
    var firestoreListener: ListenerRegistration?
    var firebaseDeleteListener: ListenerRegistration?
    var firebaseRecentListener: ListenerRegistration?
    
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
    
    func handleSend(image: UIImage?) {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        if let image = image {
            guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
            
            let ref = FirebaseManager.shared.storage.reference(withPath: UUID().uuidString)
            
            ref.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("DEBUG: Failed to upload image: \(error.localizedDescription)")
                    return
                }
                
                ref.downloadURL { url, error in
                    if let error = error {
                        print("DEBUG: Failed to download image URL: \(error.localizedDescription)")
                        return
                    }
                    
                    self.imageURL = url?.absoluteString
                    
                    print("DEBUG: Successfully uploaded image: \(url?.absoluteString ?? "")")
                }
            }
        }
            
        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        print("DEBUG: \(imageURL)")
        
        let messageData = ["fromId": fromId, "toId": toId, "text": self.messageText, "timestamp": Timestamp()] as [String : Any]
    
        let imageMessageData = ["fromId": fromId, "toId": toId, "text": self.imageURL ?? self.messageText, "timestamp": Timestamp()] as [String : Any]
        
        document.setData(imageURL != nil ? imageMessageData : messageData) { error in
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
        
        recipientDocument.setData(imageURL != nil ? imageMessageData : messageData) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
        
        messageText = ""
    }
    
    func persistRecentMessage() {
        
        guard let chatUser = chatUser else { return }
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .document(toId)
        
        let data = [
            "timestamp": Timestamp(),
            "text": self.messageText,
            "fromId": uid,
            "toId": toId,
            "profileImageUrl": chatUser.profileImageUrl,
            "username": chatUser.username
        ] as [String: Any]
        
        document.setData(data) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
        
        guard let currentUser = FirebaseManager.shared.currentUser else { return }
        
        let recipientRecentMessage = [
            "timestamp": Timestamp(),
            "text": self.messageText,
            "fromId": uid,
            "toId": toId,
            "profileImageUrl": currentUser.profileImageUrl,
            "username": currentUser.username
        ] as [String: Any]
        
        FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(toId)
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
        // Try to figure out how to delete from firestore when swiping to delete. Code reflects app deletion, but still in firestore? Double check that
    }
}
