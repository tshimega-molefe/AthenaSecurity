//
//  ServiceRequestFeature.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import Foundation
import ComposableArchitecture

struct ServiceRequestFeature: ReducerProtocol {
    
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
            return .none
            
        case .accept:
            state.route = .accepted
            return .none
            
        case .getDirections:
            state.route = .enRoute
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
