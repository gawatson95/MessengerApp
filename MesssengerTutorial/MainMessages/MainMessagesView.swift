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
    @ObservedObject var mainVm = MainMessagesVM()
    
    @State private var chatUser: ChatUser?
    @State private var shouldShowLogOutOptions: Bool = false
    @State private var shouldShowNewMessageScreen: Bool = false
    @State private var shouldNavToChatLog: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                customNavBar
                
                Divider()
                
                messagesView
                
                NavigationLink("", isActive: $shouldNavToChatLog) {
                    if let chatUser = chatUser {
                        ChatLogView(chatUser: chatUser)
                    }
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
                            .stroke(.primary, lineWidth: 1)
                    )
            } else {
                ProgressView()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let username = vm.currentUser?.username {
                    Text(username)
                        .font(.title2).bold()
                } else {
                    ProgressView()
                }
                
                HStack(spacing: 5) {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 12, height: 12)
                    Text("Online")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
        }
        .padding()
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(mainVm.recentMessages) { message in
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
                            Text(message.text)
                                .font(.callout)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        Text(message.formattedTimestamp)
                            .foregroundColor(.gray)
                            .font(.callout)
                    }
                    
                    Divider()
                }
            }
            .padding()
        }
        .overlay(alignment: .bottom) {
            Button {
                shouldShowNewMessageScreen.toggle()
            } label: {
                Text("+ New Message")
                    .bold()
                    .padding(12)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .clipShape(Capsule())
                    .padding(.horizontal)
                    .shadow(color: .black.opacity(0.5), radius: 5)
            }
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            NewMessageView { user in
                self.shouldNavToChatLog.toggle()
                self.chatUser = user
            }
        }
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainMessagesView()
            
            MainMessagesView()
                .preferredColorScheme(.dark)
        }
        .environmentObject(LoginVM())
    }
}
