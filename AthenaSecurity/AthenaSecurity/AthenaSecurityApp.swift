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
    
    var body: some Scene {
        WindowGroup {
            HomeScreenView(store: Store(
                initialState: HomeScreenFeature.State(),
                reducer: AnyReducer(HomeScreenFeature()),
                environment: ()))
                .environmentObject(userAuth)
        }
    }
}
