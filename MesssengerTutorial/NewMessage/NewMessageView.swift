//
//  NewMessageView.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/25/22.
//

import SwiftUI
import Kingfisher

struct NewMessageView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: LoginVM
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(vm.users) { user in
                    VStack(alignment: .leading) {
                        HStack {
                            KFImage(URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(.primary, lineWidth: 1)
                                )
                            
                            Text(user.email)
                        }
                        .padding()
                        
                        Divider()
                    }
                }
            }
            .navigationBarTitle("New Message")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .onAppear {
                vm.fetchAllUsers()
            }
        }
    }
}

struct NewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        NewMessageView()
            .environmentObject(LoginVM())
    }
}
