//
//  ImageUploader.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/15/22.
//

import UIKit
import FirebaseStorage
import FirebaseFirestoreSwift

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
}
