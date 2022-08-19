//
//  MainMessagesView.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/14/22.
//

import SwiftUI
import Kingfisher

struct MainMessagesView: View {
    
    @EnvironmentObject var vm: LoginVM
    
    @ObservedObject var mainVM: MainMessagesVM
    @ObservedObject var chatVM: ChatLogVM
    
    @State private var chatUser: ChatUser?
    @State private var shouldShowLogOutOptions: Bool = false
    @State private var shouldShowNewMessageScreen: Bool = false
    @State private var shouldNavToChatLog: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                customNavBar
                    .background(Color.theme.background)
                
                messagesView
                
                NavigationLink("", isActive: $shouldNavToChatLog) {
                    ChatLogView(chatUser: chatUser, mainVM: mainVM)
                }
            }
            .navigationBarHidden(true)
        }
        .confirmationDialog("Logout Options", isPresented: $shouldShowLogOutOptions) {
            Button(role: .destructive) {
                withAnimation {
                    vm.signOut()
                }
            } label: {
                Text("Log Out")
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
}

extension MainMessagesView {
    private var customNavBar: some View {
        HStack(spacing: 12) {
            if let user = vm.currentUser {
                KFImage(URL(string: user.profileImageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.theme.white, lineWidth: 1)
                    )
            } else {
                ProgressView()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let username = FirebaseManager.shared.currentUser?.username {
                    Text(username)
                        .font(.title2).bold()
                        .foregroundColor(Color.theme.white)
                } else {
                    ProgressView()
                }
                
                HStack(spacing: 5) {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.theme.accent.opacity(0.5), lineWidth: 0.4)
                                .frame(width: 12, height: 12)
                        )
                    Text("Online")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.white)
                }
            }
            
            Spacer()
            
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .resizable()
                    .foregroundColor(Color.theme.white)
                    .frame(width: 25, height: 25)
            }
        }
        .padding()
    }
    
    private var messagesView: some View {
        ZStack {
            ScrollView {
                ForEach(mainVM.recentMessages) { message in
                   Button {
                       let uid = FirebaseManager.shared.currentUser?.uid == message.fromId ? message.toId : message.fromId
                       self.chatUser = .init(snapshot: [
                                            "username": message.username,
                                            "profileImageUrl": message.profileImageUrl,
                                            "uid": uid
                                            ])
                       self.chatVM.chatUser = self.chatUser
                       self.chatVM.fetchMessages()
                       self.shouldNavToChatLog.toggle()
                    } label: {
                        VStack {
                            HStack(alignment: .top) {
                                KFImage(URL(string: message.profileImageUrl))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(.primary, lineWidth: 1)
                                    )
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(message.username)
                                        .bold()
                                        .foregroundColor(Color.theme.accent)
                                    Text(message.text)
                                        .font(.callout)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                Text("\(message.formattedTime)")
                                    .foregroundColor(.gray)
                                    .font(.callout)
                            }
                            
                            Divider()
                        }
                    }
                }
                .padding()
            }

            .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
                NewMessageView { user in
                    self.shouldNavToChatLog.toggle()
                    self.chatUser = user
                    self.chatVM.chatUser = user
                    self.chatVM.fetchMessages()
                }
        }
            Button {
                shouldShowNewMessageScreen.toggle()
            } label: {
                Text("+ New Message")
                    .bold()
                    .padding(12)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(Color.theme.background)
                    .clipShape(Capsule())
                    .padding(.horizontal)
                    .shadow(color: .black.opacity(0.5), radius: 5)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView(mainVM: MainMessagesVM(), chatVM: ChatLogVM(chatUser: nil, mainVM: MainMessagesVM()))
            .environmentObject(LoginVM())
    }
}
