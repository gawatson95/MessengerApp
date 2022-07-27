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
    
    init(snapshot: [String: Any]) {
        self.uid = snapshot["uid"] as? String ?? ""
        self.username = snapshot["username"] as? String ?? ""
        self.email = snapshot["email"] as? String ?? ""
        self.profileImageUrl = snapshot["profileImageUrl"] as? String ?? ""
    }
}
