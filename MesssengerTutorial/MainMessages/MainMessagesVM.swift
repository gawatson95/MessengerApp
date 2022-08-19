//
//  MainMessagesVM.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/31/22.
//

import Foundation
import Firebase
import FirebaseStorage

class MainMessagesVM: ObservableObject {
    
    @Published var recentMessages: [RecentMessage] = []
        
    private var firestoreListener: ListenerRegistration?
    let service = NotificationService()
    
    init() {
        fetchRecentMessages()
    }
    
    func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        firestoreListener?.remove()
        self.recentMessages.removeAll()
        
        firestoreListener = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                snapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let docId = change.document.documentID
                        
                        if let index = self.recentMessages.firstIndex(where: { message in
                            return message.documentId == docId
                        }) {
                            self.recentMessages.remove(at: index)
                        }
                        let lastestMessage = RecentMessage(documentId: docId, data: change.document.data())
                        self.recentMessages.insert(lastestMessage, at: 0)
                    } else if change.type == .removed {
                        return
                    }
                })
            }
    }
}
