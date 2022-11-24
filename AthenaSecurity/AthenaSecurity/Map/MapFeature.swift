//
//  MapFeature.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/22.
//

import Foundation
import ComposableArchitecture

struct MapFeature: ReducerProtocol {
    
    struct State: Equatable {
        var route: Route = .idle
        var serviceAcceptFeature: ServiceAcceptFeature.State?
    }
    
    enum Route: Equatable {
        case idle
        case respond
        case accepted
        case carDirections
        case trackUser
    }
    
    enum Action: Equatable {
        case serviceAcceptAction(ServiceAcceptFeature.Action)
        case fetchAndCenterSecurityLocation
        case addUserLocationAnnotation
        case addTurnByTurnDirections
        case topViewCamera
        case streetViewCamera
        case removeUserLocationAnnotation
    }
    
    var body: some ReducerProtocol<State, Action>{
        Reduce { state , action in
            
            switch action {
                
                //  TODO: We're missing the case [.respond] of the user pressing the confirm button in the Athena User App (serviceRequestView)... When user's press confirm, the action (.confirm) from the service request view must set the state.route of the Security App to ".respond". This achieves changing the state of the mapView to shift upwards to accomodate showing the user and security location on the map, above the serviceAcceptView.
                
                // case .serviceRequestAction[from the UserApp](.confirm):
                //          state.route = .respond
                //          return .none
                            
                // MARK: - Service Accept Feature Actions
                
            case .serviceAcceptAction(.reject):
                state.route = .idle
                return .none
                
            case .serviceAcceptAction(.accept):
                state.route = .accepted
                return .none
                
            case .serviceAcceptAction(.getDirections):
                state.route = .carDirections
                return .none
                
            case.serviceAcceptAction(.arrive):
                state.route = .trackUser
                return .none
                
            case .serviceAcceptAction(.complete):
                state.route = .idle
                return .none
                
                // MARK: - Map Feature Actions
                
            case .fetchAndCenterSecurityLocation:
                return .none
                
            case .addUserLocationAnnotation:
                return .none
                
            case .addTurnByTurnDirections:
                return .none
                
            case .topViewCamera:
                return .none
                
            case .streetViewCamera:
                return .none
                
            case .removeUserLocationAnnotation:
                return .none
                
            }
        }
    }
}


// TODO: Now We just need to reconfigure the MapViewRepresentable file to have its functionality be granulated within the structure of the MapFeature ReducerProtocol - A slight deviation to the CoreLocation Composable Architecture within the pointFree documentation - as We are using MapBox instead of MapKit.

// MARK: - Additional Revision
    // There is a clear overlap of actions between the mapFeature actions and ServiceAccept actions. We need to decide whether or not the service accept feature must "know" about the mapfeature i.e. configuring the mapView according to the actions of the serviceAcceptFeature OR... They features must know nothing about each other, and only be passed into as seperate actions into each of the states of the HomeScreenVie
