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
    @ObservedObject var vm: ChatLogVM
    
    @State private var toggleNavigationBarHide: Bool = false
    
    var body: some View {
        NavigationView {
            if let messageImageURL = vm.messageImageURL {
                if #available(iOS 16.0, *) {
                    KFImage(URL(string: messageImageURL))
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            withAnimation {
                                toggleNavigationBarHide.toggle()
                            }
                        }
                        .navigationTitle("Image")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    dismiss()
                                }
                            }
                        }
                        .toolbar(toggleNavigationBarHide ? .hidden : .visible)
                } else {
                    KFImage(URL(string: messageImageURL))
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            withAnimation {
                                toggleNavigationBarHide.toggle()
                            }
                        }
                        .navigationTitle("Image")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarHidden(toggleNavigationBarHide)
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
    }
}
