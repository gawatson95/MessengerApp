//
//  ImageUploader.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/15/22.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

struct ImageUploader {
    
    static func uploadImage(image: UIImage, userUid uid: String, completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("DEBUG: Failed to upload image: \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    print("DEBUG: Failed to download image URL: \(error.localizedDescription)")
                    return
                }
                
                print("DEBUG: Successfully uploaded image: \(url?.absoluteString ?? "")")
                
                guard let url = url?.absoluteString else { return }
                completion(url)
            }
        }
    }
    
    static func sendImage(userID: String, toID: String, image: UIImage, completion: @escaping(String) -> ()) {
        
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            let fer = FirebaseManager.shared.storage.reference().child(userID + "/" + toID + "/" + UUID().uuidString)
            fer.putData(imageData)
                
            let ref = FirebaseManager.shared.storage.reference(withPath: UUID().uuidString)
            ref.putData(imageData) { _ in
                ref.downloadURL { url, _ in
                    guard let url = url?.absoluteString else { return }
                    completion(url)
                }
            }
        }
    }
}
