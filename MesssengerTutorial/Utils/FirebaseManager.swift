//
//  FirebaseManager.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/14/22.
//

import Foundation
import Firebase
import FirebaseStorage

class FirebaseManager: NSObject, ObservableObject {
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    @Published var currentUser: ChatUser?
    
    override init() {
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
}
