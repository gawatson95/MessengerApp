//
//  RecentMessage.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/31/22.
//

import Foundation
import Firebase

struct RecentMessage: Identifiable {
    var id: String { documentId }
    
    let documentId: String
    let text, username: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Date
    let formattedTimestamp: String
    
    init(documentId: String, data: [String : Any]) {
        self.documentId = documentId
        self.text = data["text"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.timestamp = data["timestamp"] as? Date ?? Date()
        self.formattedTimestamp = timestamp.formatted(date: .omitted, time: .shortened)
    }
}
