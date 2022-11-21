//
//  ContentView.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import SwiftUI
import ComposableArchitecture

struct HomeScreenView: View {
    
    @EnvironmentObject var userAuth: AuthViewModel
    @EnvironmentObject var wsViewModel: WebSocketViewModel
    
    var body: some View {
    // Presentation Logic
        if !userAuth.isAuthenticated {
            LoginView()
        } else {
            // Connects Security To WebSocket
            let _ = wsViewModel.subscribeToService()
            // Configures the Home Screen
            ZStack (alignment: .topLeading) {
                    Map().edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
    }
}
