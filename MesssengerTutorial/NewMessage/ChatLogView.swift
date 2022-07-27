//
//  ChatLogView.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/27/22.
//

import SwiftUI

struct ChatLogView: View {
    
    var user: ChatUser?
    @State private var messageText: String = ""
    
    var body: some View {
        if let user = user {
            VStack {
                ScrollView {
                    ForEach(0 ..< 10) { _ in
                        LazyVStack {
                            Text(user.username)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.blue)
                                .clipShape(Capsule())
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 8)
                            Text("Hello, world!")
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                        }
                    }
                    .padding(.vertical)
                    .background(Color(.init(white: 0.95, alpha: 1)))
                    .navigationTitle(user.username)
                    .navigationBarTitleDisplayMode(.inline)
                    
                }
                
                HStack {
                    Button {
                        // ImagePicker
                    } label: {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                            .foregroundColor(.gray)
                    }

                    ZStack {
                        TextEditor(text: $messageText)
                            .padding(6)
                            .padding(.leading, 5)
                            .multilineTextAlignment(.leading)
                            .lineLimit(10)
                            .frame(maxWidth: .infinity)
//                            .frame(height: messageText.isEmpty ? 35 : nil)
                        
                        Text(messageText).opacity(0.0).padding()
                        
                        if messageText.isEmpty {
                            Text("Message")
                                .padding(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.gray.opacity(0.3))
                                .allowsHitTesting(false)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(Color.gray.opacity(0.8))
                    )
                    
                    Button {
                        // Send Image
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                    }
                }
                .padding(6)
                .padding(.horizontal, 6)
            }
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatLogView(user: ChatUser.exampleUser)
        }
    }
}
