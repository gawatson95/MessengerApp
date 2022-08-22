//
//  ChatMessage.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/29/22.
//

import Foundation
import Firebase
import SwiftUI

struct ChatMessage: Identifiable, Hashable {
    var id: String { documentId }
    let documentId: String
    let fromId: String
    let toId: String
    let text: String
    
    init(documentId: String, data: [String : Any]) {
        self.documentId = documentId
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
    }
}
