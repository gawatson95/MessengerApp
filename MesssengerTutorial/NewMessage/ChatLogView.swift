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
    @State private var dynamicHeight: CGFloat = 0.0
    
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

//                    GeometryReader { geo in
//                        ZStack {
//                            TextEditor(text: $messageText)
//                                .padding(6)
//                                .padding(.leading, 5)
//                                //.multilineTextAlignment(.leading)
//                                .lineLimit(10)
//                                .frame(maxWidth: .infinity)
//                                .frame(height: messageText.isEmpty ? 35 : dynamicHeight)
//
//                            Text(messageText).opacity(0.0).padding()
//
//
//                            if messageText.isEmpty {
//                                Text("Message")
//                                    .padding(.leading)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                    .foregroundColor(Color.gray.opacity(0.3))
//                                    .allowsHitTesting(false)
//                            }
//                        }
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 25)
//                                .strokeBorder(Color.gray.opacity(0.8))
//                    )
//                    }
                    
                    ZStack(alignment: .leading) {
                        Text(messageText)
                            .font(.system(.body))
                            .foregroundColor(.clear)
                            .background(GeometryReader {
                                Color.clear.preference(key: ViewHeightKey.self,
                                                       value: $0.frame(in: .local).size.height)
                            })
                        
                        TextEditor(text: $messageText)
                            .font(.system(.body))
                            .frame(height: max(40,dynamicHeight))
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                        
                        if messageText.isEmpty {
                            Text("Message")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.gray.opacity(0.3))
                                .allowsHitTesting(false)
                        }
                    }
                    .onPreferenceChange(ViewHeightKey.self) { dynamicHeight = $0 }
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .strokeBorder(Color.gray.opacity(0.3))
                    )
                    .padding(.leading)

                    
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

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
