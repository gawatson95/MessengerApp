//
//  RecentMessage.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/31/22.
//

import Foundation
import Firebase

struct RecentMessage: Identifiable, Hashable {
    var id: String { documentId }
    
    let documentId: String
    let text, username: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Timestamp
    
    init(documentId: String, text: String, username: String, fromId: String, toId: String, profileImageUrl: String, timestamp: Date) {
        self.documentId = documentId
        self.text = text
        self.username = username
        self.fromId = fromId
        self.toId = toId
        self.profileImageUrl = profileImageUrl
        self.timestamp = Timestamp(date: Date())
    }
    
    init(documentId: String, data: [String : Any]) {
        self.documentId = documentId
        self.text = data["text"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
    
    var formattedTime: String {
        let dateTimestamp = timestamp.dateValue()
        let dayAgo = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: .now)!
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        
        if dateTimestamp < dayAgo {
            return formatter.string(from: dateTimestamp)
        } else {
            return dateTimestamp.formatted(date: .omitted, time: .shortened)
        }
    }
    
    static let exampleRecentMessage = RecentMessage(documentId: "", text: "Test message", username: "Lady Gaga", fromId: "", toId: "", profileImageUrl: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2670&q=80", timestamp: Date.now)
}
