//
//  ChatLogView.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/27/22.
//

import SwiftUI
import Kingfisher

struct ChatLogView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var vm: ChatLogVM
    
    @Namespace var bottomId
    
    @State private var confirmDeleteDialog: Bool = false
    @State private var showImagePicker: Bool = false
    @State var image: UIImage?
    @State var imageMessage: Image?
    @State private var toggleTextEditor: Bool = false
    @State var imageURL: String = ""
    
    
    @State var showFullScreenImage: Bool = false
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?, mainVM: MainMessagesVM) {
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser, mainVM: mainVM)
    }
    
    @State private var dynamicHeight: CGFloat = 0.0
    
    var body: some View {
        if let user = vm.chatUser {
            VStack {
                ScrollView {
                    ScrollViewReader { scroll in
                        ForEach(vm.chatMessages) { message in
                            LazyVStack {
                                if message.text.hasPrefix("https://firebasestorage") {
                                    KFImage(URL(string: message.text))
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .frame(maxHeight: 175)
                                        .frame(maxWidth: .infinity, alignment: message.fromId == user.uid ? .leading : .trailing)
                                        .onTapGesture {
                                            imageURL = message.text
                                            print(imageURL)
                                            showFullScreenImage.toggle()
                                        }
                                } else {
                                    Text(message.text)
                                        .foregroundColor(message.fromId == user.uid ? Color.theme.accent : .white)
                                        .padding(12)
                                        .background(message.fromId == user.uid ? Color.white : Color.theme.background)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .frame(maxWidth: .infinity, alignment: message.fromId == user.uid ? .leading : .trailing)
                                }
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
                    .navigationBarItems(
                        trailing:
                            !vm.chatMessages.isEmpty ? Image(systemName: "trash")
                                .foregroundColor(.red)
                                .onTapGesture {
                                    confirmDeleteDialog.toggle()
                                } : nil
                        )
                    .navigationBarTitleDisplayMode(.inline)
                }
                
                bottomChatBar
            }
            .fullScreenCover(isPresented: $showFullScreenImage, content: {
                let imageURL = imageURL
                FullScreenImageView(imageURL: imageURL)
            })
            .background(Color(.init(white: 0.95, alpha: 1)))
            .onDisappear {
                vm.firestoreListener?.remove()
            }
            .padding(.top, 1)
            .alert("Confirm Delete", isPresented: $confirmDeleteDialog) {
                Button("Delete", role: .destructive) {
                    vm.deleteChatLog()
                    dismiss()
                }
            } message: {
                Text("Confirm deletion of your messages with \(user.username). This action cannot be undone.")
            }
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatLogView(chatUser: ChatUser.exampleUser, mainVM: MainMessagesVM())
        }
    }
}

extension ChatLogView {
    private var bottomChatBar: some View {
        HStack {
            Button {
                showImagePicker.toggle()
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
                
                if imageMessage == nil {
                    TextEditor(text: $vm.messageText)
                        .padding(.leading, 10)
                        .font(.system(.body))
                        .frame(height: max(40,dynamicHeight))
                }
                
                if imageMessage != nil {
                    if let imageMessage = imageMessage {
                        imageMessage
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .frame(height: 175)
                            .background(GeometryReader {
                                Color.clear.preference(key: ViewHeightKey.self,
                                                       value: $0.frame(in: .local).size.height)
                            })
                            .padding(.leading, 10)
                    }
                } else if vm.messageText.isEmpty {
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
                if let image = image {
                    ImageUploader.sendImage(image: image) { url in
                        let imageURL = url
                        vm.handleImageSend(url: imageURL)
                    }
                } else {
                    vm.handleSend()
                }
                image = nil
                imageMessage = nil
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .foregroundColor(Color.theme.background)
                    .scaledToFit()
                    .frame(width: 25)
            }
        }
        .padding(6)
        .padding(.horizontal, 6)
        .background(Color.white)
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $image)
        }
    }
    
    func loadImage() {
        guard let image = image else { return }
        imageMessage = Image(uiImage: image)
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
