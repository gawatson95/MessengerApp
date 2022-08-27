//
//  FullScreenImageView.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 8/26/22.
//

import SwiftUI
import Kingfisher

struct FullScreenImageView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var imageURL: String
    
    var body: some View {
        NavigationView {
            KFImage(URL(string: imageURL))
                .resizable()
                .scaledToFit()
                
            .navigationTitle("Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FullScreenImageView_Previews: PreviewProvider {
    static var previews: some View {
        FullScreenImageView(imageURL: "https://images.unsplash.com/photo-1661503390019-86b9193edb4d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1281&q=80")
    }
}
