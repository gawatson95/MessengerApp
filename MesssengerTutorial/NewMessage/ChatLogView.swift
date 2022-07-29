//
//  ChatLogView.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/27/22.
//

import SwiftUI

struct ChatLogView: View {
    
    @ObservedObject var vm: ChatLogVM
    @Namespace var bottomId
    
    var chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self.vm = ChatLogVM(chatUser: chatUser)
    }
    
    @State private var dynamicHeight: CGFloat = 0.0
    
    var body: some View {
        if let user = chatUser {
            VStack {
                ScrollView {
                    ScrollViewReader { scroll in
                        ForEach(vm.chatMessages) { message in
                            LazyVStack {
                                Text(message.text)
                                    .foregroundColor(message.fromId == user.uid ? .black : .white)
                                    .padding(12)
                                    .background(message.fromId == user.uid ? Color.white : Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .frame(maxWidth: .infinity, alignment: message.fromId == user.uid ? .leading : .trailing)
                            }
                            .padding(.horizontal, 8)
                        }
                        .onAppear {
                            withAnimation {
                                scroll.scrollTo(bottomId, anchor: .bottom)
                            }
                        }
                        .onChange(of: vm.chatMessages.count) { _ in
                            withAnimation {
                                scroll.scrollTo(bottomId, anchor: .bottom)
                            }
                        }
                        
                        Text("")
                            .id(bottomId)
                    }
                    .padding(.vertical)
                    .navigationTitle(user.username)
                    .navigationBarTitleDisplayMode(.inline)
                }
                .background(Color(.init(white: 0.95, alpha: 1)))
                
                bottomChatBar
            }
            .padding(.top, 1)
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatLogView(chatUser: ChatUser.exampleUser)
        }
    }
}

extension ChatLogView {
    private var bottomChatBar: some View {
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
            
            ZStack(alignment: .leading) {
                Text(vm.messageText)
                    .padding(10)
                    .font(.system(.body))
                    .foregroundColor(.clear)
                    .background(GeometryReader {
                        Color.clear.preference(key: ViewHeightKey.self,
                                               value: $0.frame(in: .local).size.height)
                    })
                
                TextEditor(text: $vm.messageText)
                    .padding(.leading, 10)
                    .font(.system(.body))
                    .frame(height: max(40,dynamicHeight))
                
                if vm.messageText.isEmpty {
                    Text("Message")
                        .padding(.leading)
                        .foregroundColor(Color.gray.opacity(0.3))
                        .allowsHitTesting(false)
                }
                
                RoundedRectangle(cornerRadius: 25)
                    .strokeBorder(Color.gray.opacity(0.3))
                    .frame(height: max(40,dynamicHeight))
            }
            .onPreferenceChange(ViewHeightKey.self) { dynamicHeight = $0 }

            Button {
                vm.handleSend()
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
    
    private var messagesView: some View {
        VStack {
            ScrollView {
                ForEach(0 ..< 10) { _ in
                    LazyVStack {
                        Text("user.username")
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
                
            }
        }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
