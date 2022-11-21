//
//  SideMenuView.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import SwiftUI
import ComposableArchitecture

struct SideMenu: View {
    
    let store: Store<SideMenuFeature.State, SideMenuFeature.Action>
    
    var body: some View {
        
        WithViewStore(self.store) { viewStore in
            
            switch viewStore.state.route {
                
            case .idle:
                // Hamburger Button
                Button {
                    viewStore.send(.open)
                } label: {
                    Image(systemName: "list.bullet")
                }
                .font(.title)
                .padding(.leading)

            case .showMenu:
                Button {
                    viewStore.send(.close)
                } label: {
                    Image(systemName: "list")
                }
                .font(.title)
                .padding(.leading)
            }
        }
    }
}

struct SideMenu_Previews: PreviewProvider {
    static var previews: some View {
        SideMenu(store: Store(initialState: SideMenuFeature.State(),
                              reducer: AnyReducer(SideMenuFeature()),
                              environment: ()))
    }
}
