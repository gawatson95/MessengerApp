//
//  ContentView.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/15/22.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var vm: LoginVM
    
    var body: some View {
        if vm.userSession == nil {
            LoginView(mainVM: MainMessagesVM())
        } else {
            MainMessagesView(mainVM: MainMessagesVM(), chatVM: ChatLogVM(chatUser: ChatUser.exampleUser, mainVM: MainMessagesVM()))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LoginVM())
    }
}
