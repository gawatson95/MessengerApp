//
//  UserService.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/15/22.
//

import Firebase
import FirebaseFirestoreSwift

struct UserService {
    
    func fetchCurrentUser(withUid uid: String, completion: @escaping(ChatUser) -> Void) {
        FirebaseManager.shared.firestore.collection("users")
            .document(uid)
            .getDocument { snapshot, _ in
                
                guard let snapshot = snapshot?.data() else { return }
                
                let chatUser = ChatUser.init(snapshot: snapshot)
                completion(chatUser)
            }
    }
    
    func fetchAllUsers(completion: @escaping([ChatUser]) -> Void) {
        var allUsers = [ChatUser]()
        
        FirebaseManager.shared.firestore.collection("users")
            .getDocuments { docSnapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                docSnapshot?.documents.forEach { snapshot in
                    let data = snapshot.data()
                    let user = ChatUser(snapshot: data)
                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                        allUsers.append(.init(snapshot: data))
                    }
                }
                completion(allUsers)
            }
    }
}
