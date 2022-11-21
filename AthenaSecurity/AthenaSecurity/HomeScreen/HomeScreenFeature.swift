//
//  HomeScreenFeature.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import ComposableArchitecture

struct HomeScreenFeature: ReducerProtocol {
    
    struct State: Equatable {
        var showMenu = true
        var route: Route = .showMenu
        var connectivityState = ConnectivityState.disconnected
        var serviceRequestFeature: ServiceRequestFeature.State?
        var sideMenuFeature: SideMenuFeature.State
    }
    
    enum Route: Equatable {
        case showMenu
        case respond
        case accepted
        case arrived
        case completed
        case rejected
        case directions
    }
    
    enum ConnectivityState: Equatable {
        case connected
        case connecting
        case disconnected
    }
    
    enum Action: Equatable {
        case serviceRequestAction(ServiceRequestFeature.Action)
        case onAppear
        case reject
        case connectOrDisconnect
        case sendButtonTapped
        case sendResponse(didSucced: Bool)
    }
    
    
    
}
