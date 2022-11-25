//
//  MapFeature.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/22.
//

import Foundation
import SwiftUI
import MapboxMaps
import ComposableArchitecture

struct MapFeature: ReducerProtocol {
    
    struct State: Equatable {
        var route: Route = .idle
        var securityLocation: Location
        var userLocation: Location?
        var isTapped: Bool
        var isShowingMyCircle: Bool
        var mapFrameSize: CGRect

    }
    
    enum Route: Equatable {
        case idle
        case showingUser
        case showingDirections
        case trackingUser
        case removingUser
            }
    
    enum Action: Equatable {
        case showUser
        case getDirections
        case trackUser
        case removeUser
    }
    
    var body: some ReducerProtocol<State, Action>{
        Reduce { state , action in
            
            switch action {
                
                // MARK: - Map Feature Actions
                
            case .showUser:
                return .none
                
            case .getDirections:
                return .none
                
            case .trackUser:
                return .none
                
            case .removeUser:
                return .none
            }
        }
    }
}

