//
//  ChatUser.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/14/22.
//

import Foundation

struct ChatUser: Codable, Identifiable {
    
    var id: String { uid }
    let uid: String
    let username: String
    let email: String
    let profileImageUrl: String
    
    init(uid: String, username: String, email: String, profileImageUrl: String) {
        self.uid = uid
        self.username = username
        self.email = email
        self.profileImageUrl = profileImageUrl
    }
    
    init(snapshot: [String: Any]) {
        self.uid = snapshot["uid"] as? String ?? ""
        self.username = snapshot["username"] as? String ?? ""
        self.email = snapshot["email"] as? String ?? ""
        self.profileImageUrl = snapshot["profileImageUrl"] as? String ?? ""
    }
    
    static let exampleUser = ChatUser(uid: "123", username: "Username", email: "email@email.com", profileImageUrl: "https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1480&q=80")
}
