//
//  LoginVM.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/15/22.
//

import SwiftUI
import Firebase

class LoginVM: ObservableObject {
    
    @Published var userSession: Firebase.User?
    @Published var tempUserSession: Firebase.User?
    @Published var users = [ChatUser]()
    @Published var currentUser: ChatUser?
    
    @Published var loginMessage: String = ""
    @Published var didAuthUser: Bool = false
    
    private let service = UserService()
    
    init() {
        self.userSession = Auth.auth().currentUser
        self.fetchUser()
    }
    
    func loginWithEmail(withEmail email: String, password: String) {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Unable to to login user: \(error.localizedDescription)")
                self.loginMessage = error.localizedDescription
                return
            }
            
            print("DEBUG: Login success")
            self.loginMessage = "Login successful"
            
            guard let user = result?.user else { return }
            self.userSession = user
            self.fetchUser()
        }
    }
    
    func register(withEmail email: String, username: String, password: String, image: UIImage) {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Unable to to create user: \(error.localizedDescription)")
                self.loginMessage = error.localizedDescription
                return
            }
            
            guard let user = result?.user else { return }
            
            let data = ["email": email,
                        "username": username,
                        "uid": user.uid]
            
            Firestore.firestore().collection("users")
                .document(user.uid)
                .setData(data) { _ in
                    self.didAuthUser = true
                }
            
            self.tempUserSession = user
            
            self.uploadImage(image)
            
            print("DEBUG: Success creating user")
            
            self.loginMessage = "Logging you in"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.userSession = user
                self.fetchUser()
            }
        }
    }
    
    func uploadImage(_ image: UIImage) {
        
        if let uid = tempUserSession?.uid {
            ImageUploader.uploadImage(image: image, userUid: uid) { url in
                Firestore.firestore().collection("users")
                    .document(uid)
                    .updateData(["profileImageUrl" : url])
            }
        }
    }
    
    func fetchUser() {
        guard let uid = self.userSession?.uid else { return }
        
        service.fetchCurrentUser(withUid: uid) { user in
            FirebaseManager.shared.currentUser = user
            self.currentUser = user
        }
    }
    
    func fetchAllUsers() {
        service.fetchAllUsers() { allUsers in
            self.users = allUsers
        }
    }
    
    func signOut() {
        userSession = nil
        try? Auth.auth().signOut()
        didAuthUser = false
    }
}
