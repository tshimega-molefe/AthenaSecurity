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
    
    let store: Store<HomeScreenFeature.State, HomeScreenFeature.Action>
    
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
                IfLetStore(
                    self.store.scope(
                        state: \.sideMenuFeature,
                        action: HomeScreenFeature.Action.sideMenuAction)
                ) { requestStore in
                    SideMenu(store: requestStore)
                }
//                IfLetStore(
//                    self.store.scope(
//                        state: \.serviceAcceptFeature,
//                        action: HomeScreenFeature.Action.serviceAcceptAction)
//                ) { requestStore in
//                    ServiceAcceptView(store: requestStore)
//                }
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView(store: Store(
            initialState: HomeScreenFeature.State(),
            reducer: AnyReducer(HomeScreenFeature()),
            environment: ()))
    }
}
