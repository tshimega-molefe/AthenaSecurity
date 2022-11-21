//
//  ServiceAcceptFeature.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import Foundation
import ComposableArchitecture

struct ServiceAcceptFeature: ReducerProtocol {
    
    struct State: Equatable {
        // TODO: Create User Data model so data can be pulled into User View
        //var RequestingUser: [RequestingUser] = []
        
        var route: Route = .respond
    }
    
    enum Route: Equatable {
        case respond
        case accepted
        case enRoute
        case arrived
        case completed
    }
    
    
    enum Action: Equatable {
        case reject
        case accept
        case getDirections
        case arrive
        case complete
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
            
        case .reject:
            state.route = .completed
            print("DEBUG: Handle Reject Emergency...")
            return .none
            
        case .accept:
            state.route = .accepted
            print("DEBUG: Handle Accept Emergency...")
            return .none
            
        case .getDirections:
            state.route = .enRoute
            print("DEBUG: Run Get Directions API with MapBox..")
            return .none
    
        case .arrive:
            state.route = .arrived
            return .none
            
        case .complete:
            state.route = .completed
            return .none
        }
    }
}
