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
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

struct MapFeature: ReducerProtocol {
    
    struct State: Equatable {
        var mapStatus: MapStatus = .idle
        var route: Route?
        var securityLocation: CLLocationCoordinate2D?
        var userLocation: CLLocationCoordinate2D?
        var tappedCoordinate: CLLocationCoordinate2D?
        //        var isTapped: Bool
        //        var isShowingMyCircle: Bool
        //        var mapFrameSize: CGRect
        
    }
    
    enum MapStatus: Equatable {
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
        case calculateRoute(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D)
        case routeResponse(TaskResult<Route>)
        case longPress(CLLocationCoordinate2D)
    }
    
    @Dependency(\.navigation) private var navigation
    
    var body: some ReducerProtocol<State, Action>{
        Reduce { state , action in
            switch action {
                
            case .showUser:
                return .none
                
            case .getDirections:
                return .none
                
            case .trackUser:
                return .none
                
            case .removeUser:
                return .none
                
            case .calculateRoute(origin: let origin, destination: let destination):
                let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
                let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
                // The Destination will need to be fed in the location coordinate from the User Model that's communicating with the Security in the WebSocket Group
                
                let routeOptions = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
                
                return .task {
                    await .routeResponse(TaskResult { try await navigation.calculateRoute(routeOptions) })
                }
                
            case let .longPress(coordinate):
                state.tappedCoordinate = coordinate
                return .none
                
            case let .routeResponse(.success(result)):
                state.route = result
                return .none
                
            case let .routeResponse(.failure(error)):
                print(error)
                return .none
            }
        }
    }
}

