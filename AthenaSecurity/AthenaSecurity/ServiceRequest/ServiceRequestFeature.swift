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
        // TODO: Create service provider model so data can be pulled into top block
        //var serviceProviders: [ServiceProviders] = []
        
        var route: Route = .idle
    }
    
    enum Route: Equatable {
        case idle
        case confirmed
        case accepted
        case completed
    }
    
    enum Action: Equatable {
        case confirm
        case accept
        case complete
        case updatePaymentMethod
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .confirm:
            state.route = .confirmed
            return .none
            
        case .accept:
            state.route = .accepted
            return .none
            
        case .complete:
            state.route = .completed
            return .none
            
        case .updatePaymentMethod:
            return .none
        }
    }
}
