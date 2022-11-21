//
//  SideMenuFeature.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import Foundation
import ComposableArchitecture

struct SideMenuFeature: ReducerProtocol {
 
    struct State: Equatable {
        // TODO: Create Security User Data model so data can be pulled into User Profile Section of Side Menu
        
        //var SecurityUserData: [UserData] = []
        
        var route: Route = .idle
    }
    
    enum Route: Equatable {
        case idle
        case showMenu
    }
    
    enum Action: Equatable {
        case open
        case close
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .open:
            state.route = .showMenu
            print("DEBUG: Open The Side Menu..")
            return .none
            
        case .close:
            state.route = .idle
            print("DEBUG: Close The Side Menu..")
            return .none
        }
    }
}
