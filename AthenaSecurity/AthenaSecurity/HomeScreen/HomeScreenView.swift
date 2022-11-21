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
            WithViewStore(self.store) { viewStore in
                ZStack (alignment: .bottom){
                    MapViewRepresentable().edgesIgnoringSafeArea(.all)
                    
                    ZStack(alignment: .topLeading) {
                        IfLetStore(
                            self.store.scope(
                                state: \.sideMenuFeature,
                                action: HomeScreenFeature.Action.sideMenuAction)
                        ) { sideMenuStore in
                            SideMenu(store: sideMenuStore)
                        }
                    }
                    
                    IfLetStore(
                        self.store.scope(
                            state: \.serviceAcceptFeature,
                            action: HomeScreenFeature.Action.serviceAcceptAction)
                    ) { requestStore in
                        ServiceAcceptView(store: requestStore)
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                // On Appear is for Testing...
                .onAppear {
                    viewStore.send(.onAppear)
                }
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
