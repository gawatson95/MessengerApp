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
    let timestamp: Timestamp
    
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
}
