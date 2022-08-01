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
    
    @Published var recentMessages = [RecentMessage]()
    
    init() {
        fetchRecentMessages()
    }
    
    private func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore
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
                    let docId = change.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { message in
                        return message.documentId == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                        
                   self.recentMessages.insert(RecentMessage(documentId: docId, data: change.document.data()), at: 0)
                })
            }
    }
}
