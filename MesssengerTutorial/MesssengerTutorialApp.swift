//
//  MesssengerTutorialApp.swift
//  MesssengerTutorial
//
//  Created by Grant Watson on 7/7/22.
//

import SwiftUI
import FirebaseCore

@main
struct MesssengerTutorialApp: App {
    
    @StateObject var vm = LoginVM()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
        }
    }
}
