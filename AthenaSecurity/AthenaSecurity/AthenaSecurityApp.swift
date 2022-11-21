//
//  AthenaSecurityApp.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import SwiftUI
import ComposableArchitecture

@main
struct AthenaSecurityApp: App {
    
    @StateObject var userAuth = AuthViewModel()
    @StateObject var wsViewModel = WebSocketViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeScreenView()
                .environmentObject(userAuth)
                .environmentObject(wsViewModel)
        }
    }
}
