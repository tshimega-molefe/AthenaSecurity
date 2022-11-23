//
//  HomeScreenFeature.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import ComposableArchitecture

struct HomeScreenFeature: ReducerProtocol {
    
    struct State: Equatable {
        var isPresented = false
        var showMenu = false
        var onDuty = false
        var route: Route = .respond
        var connectivityState = ConnectivityState.disconnected
        var serviceAcceptFeature: ServiceAcceptFeature.State?
        var sideMenuFeature: SideMenuFeature.State?
        var mapFeature: MapFeature.State?
    }
    
    enum Route: Equatable {
        case respond
        case rejected
        case accepted
        case directions
        case arrived
        case completed
    }
    
    enum ConnectivityState: Equatable {
        case connected
        case connecting
        case disconnected
    }
    
    enum Action: Equatable {
        case serviceAcceptAction(ServiceAcceptFeature.Action)
        case sideMenuAction(SideMenuFeature.Action)
        case mapAction(MapFeature.Action)
        case onAppear
        case cancel
        case connectOrDisconnect
        case sendButtonTapped
        case sendResponse(didSucced: Bool)
    }
    
    var body: some ReducerProtocol<State, Action>{
        Reduce { state , action in
            
            enum WebSocketID {}
            
            switch action {
                
                // MARK: - Side Menu Actions
                
            case .sideMenuAction(.open):
                state.showMenu = true
                return .none
                
            case .sideMenuAction(.close):
                state.showMenu = false
                return .none
                
            case .sideMenuAction(.onDuty):
                state.onDuty = true
                return .none
                
            case .sideMenuAction(.offDuty):
                state.onDuty = false
                return .none
                
                // MARK: - Service Accept Actions
               
            case .serviceAcceptAction(.reject):
                return .none
                
            case .serviceAcceptAction(.accept):
                return .none
                
            case .serviceAcceptAction(.getDirections):
                return .none
                
            case .serviceAcceptAction(.arrive):
                return .none
                
            case .serviceAcceptAction(.complete):
                return .none
                
                // MARK: - Map Feature Actions
                
                    // Service Accept Actions that affect the mapView
                
            case .mapAction(.serviceAcceptAction(.reject)):
                return .none
                
            case .mapAction(.serviceAcceptAction(.accept)):
                return .none
                
            case .mapAction(.serviceAcceptAction(.getDirections)):
                return .none
                
            case .mapAction(.serviceAcceptAction(.arrive)):
                return .none
                
            case .mapAction(.serviceAcceptAction(.complete)):
                return .none
                
                // Map Feature Actions that affect the mapView
                
            case .mapAction(.fetchAndCenterSecurityLocation):
                return .none
                
            case .mapAction(.addUserLocationAnnotation):
                return .none
                
            case .mapAction(.addTurnByTurnDirections):
                return .none
                
            case .mapAction(.streetViewCamera):
                return .none
                
            case .mapAction(.topViewCamera):
                return .none
                
            case .mapAction(.removeUserLocationAnnotation):
                return .none
                
                // When the home Screen Feature appears.
                
            case .onAppear:
                //state.serviceAcceptFeature = nil
                state.isPresented = true
                state.serviceAcceptFeature = ServiceAcceptFeature.State()
                return .none
                
            case .cancel:
                // state.serviceAcceptFeature = nil
                state.isPresented = false
                return .none
                
                // MARK: - WebSocket Enum
                    
            case .connectOrDisconnect:
                switch state.connectivityState {
                    
                case .connected, .connecting:
                    state.connectivityState = .disconnected
                    return .cancel(id: WebSocketID.self)
                    
                case .disconnected:
                    state.connectivityState = .connecting
                    return .none
                }
            
            case .sendButtonTapped:
                return .none
                
            case .sendResponse(didSucced: _):
                return .none
                
            }
        }
        .ifLet(\.sideMenuFeature, action: /Action.sideMenuAction) {
            SideMenuFeature()
        }
        .ifLet(\.serviceAcceptFeature, action: /Action.serviceAcceptAction) {
            ServiceAcceptFeature()
        }
        
        // TODO: Add the ifLet etc.. for the MapFeature, as immediately above.
    }
}
