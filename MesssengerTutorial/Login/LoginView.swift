//
//  ContentView.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/7/22.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct LoginView: View {
    @EnvironmentObject var vm: LoginVM
    @ObservedObject var mainVM: MainMessagesVM
    
    @State private var isLoginMode: Bool = true
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State private var showPicker: Bool = false
    @State private var image: UIImage?
    @State private var profileImage: Image?
    
    var body: some View {
        NavigationView {
            
            VStack(spacing: 30) {
                Picker(selection: $isLoginMode, content: {
                    Text("Login")
                        .tag(true)
                    Text("Create Account")
                        .tag(false)
                }, label: {
                    Text("Hello")
                })
                .pickerStyle(.segmented)
                            
                if !isLoginMode {
                    Button {
                        showPicker.toggle()
                    } label: {
                        if let image = profileImage {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                    )
                                .shadow(color: .black.opacity(0.3), radius: 10)
                        } else {
                            VStack {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 64, height: 64)
                                
                                Text("Add Profile Picture")
                                    .bold()
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                VStack(spacing: 10) {
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                        
                        if !isLoginMode {
                            TextField("Username", text: $username)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                        }
                        
                        SecureField("Password", text: $password)
                            .padding()
                    }
                    .padding(.horizontal, 12)
                    .background(.white)
                    .clipShape(Capsule())
                }
                
                Button {
                    handleAction()
                } label: {
                    Text(isLoginMode ? "Login" : "Create Account")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(.blue)
                        .clipShape(Capsule())
                }
                
                Text(vm.loginMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)

                Spacer()
                
            }
            .fullScreenCover(isPresented: $showPicker, onDismiss: loadImage) {
                ImagePicker(image: $image)
            }
            .padding()
            .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .onAppear {
                vm.loginMessage = ""
            }
        }
    }
    
    private func handleAction() {
        if isLoginMode {
            vm.loginWithEmail(withEmail: email, password: password)
            mainVM.fetchRecentMessages()
        } else {
            guard let image = image else { return }
            vm.register(withEmail: email, username: username, password: password, image: image)
        }
    }
    
    func loadImage() {
        guard let image = image else { return }
        profileImage = Image(uiImage: image)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(mainVM: MainMessagesVM())
            .environmentObject(LoginVM())
    }
}
