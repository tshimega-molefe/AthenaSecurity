//
//  HomeScreenFeature.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import Foundation
import ComposableArchitecture
import CoreLocation
import ServiceMap

struct HomeScreenFeature: ReducerProtocol {
    
    struct State: Equatable {
        var showMenu = false
        var onDuty = false
        var connectivityState = ConnectivityState.disconnected
        var serviceAcceptFeature: ServiceAcceptFeature.State?
        var sideMenuFeature: SideMenuFeature.State?
        var mapFeature: MapFeature.State?
        var emergency: EmergencyModel = EmergencyModel()
    }
    
    enum Route: Equatable {
        case idle
        case respond
        case rejected
        case accepted
        case directions
        case arrived
    }
    
    enum ConnectivityState: Equatable {
        case connected
        case connecting
        case disconnected
    }
    
    @Dependency(\.websocket) private var websocket
    @Dependency(\.mainQueue) private var mainQueue
    
    enum Action: Equatable {
        case serviceAcceptAction(ServiceAcceptFeature.Action)
        case sideMenuAction(SideMenuFeature.Action)
        case mapAction(MapFeature.Action)
        case onAppear
        case cancel
        case connectOrDisconnect
        case sendResponse(didSucceed: Bool)
        case webSocket(WebSocketClientComposable.Action)
        case receivedSocketMessage(TaskResult<WebSocketClientComposable.Message>)
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
                let messageToSend = "{\"type\": \"accept.emergency\", \"id\": \"\(state.emergency.id ?? "")\"}"
                return .task {
                    try await websocket.send(WebSocketID.self, .string(messageToSend))
                    return .sendResponse(didSucceed: true)
                } catch: { _ in
                        .sendResponse(didSucceed: false)
                }
                .cancellable(id: WebSocketID.self)
                
            case .serviceAcceptAction(.getDirections):
                return .none
                
            case .serviceAcceptAction(.arrive):
                let messageToSend = "{\"type\": \"start.emergency\", \"id\": \"\(state.emergency.id ?? "")\"}"
                return .task {
                    try await websocket.send(WebSocketID.self, .string(messageToSend))
                    return .sendResponse(didSucceed: true)
                } catch: { _ in
                        .sendResponse(didSucceed: false)
                }
                .cancellable(id: WebSocketID.self)
                
            case .serviceAcceptAction(.complete):
                state.serviceAcceptFeature = nil
                let messageToSend = "{\"type\": \"complete.emergency\", \"id\": \"\(state.emergency.id ?? "")\"}"
                return .task {
                   
                    try await websocket.send(WebSocketID.self, .string(messageToSend))
                    return .sendResponse(didSucceed: true)
                } catch: { _ in
                        .sendResponse(didSucceed: false)
                }
                .cancellable(id: WebSocketID.self)
                
                
                
                // When the home Screen Feature appears.
                
            case .onAppear:
                state.mapFeature = MapFeature.State(mapMode: .security)
                return .none
                
            case .cancel:
                //state.serviceAcceptFeature = nil
                return .none
                
                // MARK: - WebSocket Enum
                
            case .connectOrDisconnect:
                switch state.connectivityState {
                    
                case .connected, .connecting:
                    state.connectivityState = .disconnected
                    return .cancel(id: WebSocketID.self)
                    
                case .disconnected:
                    
                    state.connectivityState = .connecting
                    
                    return .run { send in
                        let actions = await websocket.open(WebSocketID.self, URL(string: "ws://localhost:8000")!, [])
                        
                        await withThrowingTaskGroup(of: Void.self) { taskGroup in
                            for await action in actions {
                                await send(.webSocket(action))
                                
                                switch action {
                                case .didOpen:
                                    taskGroup.addTask {
                                        
                                        let accessToken: String
                                        
                                        if let data = KeychainHelper.standard.read(service: "access-token"){
                                            if let token = String(data: data, encoding: .utf8){
                                                print("DEBUG: GOT AN ACCESS TOKEN")
                                                accessToken = token
                                            }
                                            else {
                                                accessToken = ""
                                                print("DEBUG: Something went wrong setting access token string value")
                                            }
                                        }
                                        else {
                                            accessToken = ""
                                            print("DEBUG: No webSocket access token found in keychain")
                                        }
                                        
                                        let messageToSend = "{\"token\": \" \(accessToken)\"}"
                                        try await websocket.send(WebSocketID.self, .string(messageToSend))
                                        
                                        while true {
                                            try await mainQueue.sleep(for: .seconds(10))
                                            try await websocket.sendPing(WebSocketID.self)
                                        }
                                    }
                                    taskGroup.addTask {
                                        for await result in try await websocket.receive(WebSocketID.self) {
                                            await send(.receivedSocketMessage(result))
                                        }
                                    }
                                    
                                case .didClose:
                                    return
                                }
                            }
                        }
                    } catch: { _, _ in
                    }
                    .cancellable(id: WebSocketID.self)
                }
                
            case .webSocket(.didOpen):
                state.connectivityState = .connected
                return .none
                
            case .webSocket(.didClose):
                state.connectivityState = .disconnected
                return .cancel(id: WebSocketID.self)
                
            case let .receivedSocketMessage(.success(message)):
                if case let .string(string) = message {
                    
                    let decoder = JSONDecoder()
                    state.emergency = try! decoder.decode(EmergencyModel.self, from: string.data(using: .utf8)!)
                    
                    let type = state.emergency.type ?? ""
                    
                    switch type {
                        
                    case "renew.emergency":
                        switch state.emergency.status {
                        case "ACCEPTED":
                            state.serviceAcceptFeature = ServiceAcceptFeature.State(route: .accepted)
                            return .none
                        
                        case "IN PROGRESS":
                            state.serviceAcceptFeature = ServiceAcceptFeature.State(route: .arrived)
                        
                        case "REQUESTED":
                            state.serviceAcceptFeature = ServiceAcceptFeature.State(route: .respond)
                            
                        default:
                            return .none
                            
                        }
                        
                    case "create.emergency":
                        state.serviceAcceptFeature = ServiceAcceptFeature.State()
                        
                    case "accept.emergency":
                        //return the map action for adding user + changing state
                        return .none
                        
                    case "update.emergency":
                        if let citizen = state.emergency.citizen {
                            return .task { [citizenCoordinate = citizen.coordinate] in
                                
                                let lat = citizenCoordinate.latitude
                                let long = citizenCoordinate.longitude
                                let coordinate = CLLocationCoordinate2DMake(lat, long)
                                
                                return .mapAction(.updateCitizenLocation(coordinate))
                            }
                        }
                        
                    case "cancel.emergency":
                        state.mapFeature?.citizenLocation = nil
                        state.serviceAcceptFeature = nil
                        return .none
                        
                    case "start.emergency":
                        return .none
                        
                    case "complete.emergency":
                        state.mapFeature?.citizenLocation = nil
                        state.serviceAcceptFeature = nil
                        return.none
                        
                    default:
                        return .none
                    }
                }
                
                return .none
                
            case .receivedSocketMessage(.failure):
                return .none
                
            case .sendResponse(didSucceed: let didSucceed):
                print(didSucceed)
                return .none
                
                
            case .mapAction(.calculateRoute(_, _)):
                return .none
            case .mapAction(.longPress(_)):
                return .none
            case .mapAction(.routeResponse(_)):
                return .none
            case .mapAction(.getDirections):
                return .none
            case .mapAction(.removeCitizen):
                return .none
                
            case .mapAction(.updateCitizenLocation(_)):
                return .none
                
            case let .mapAction(.updateSecurityLocation(newCoordinate)):
                
                let messageToSend = "{\"type\": \"update.location\", \"security\": { \"coordinate\": { \"latitude\": \(newCoordinate.latitude), \"longitude\": \(newCoordinate.longitude) } } }"
                
                return .task {
                    try await websocket.send(WebSocketID.self, .string(messageToSend))
                    return .sendResponse(didSucceed: true)
                } catch: { _ in
                        .sendResponse(didSucceed: false)
                }
                .cancellable(id: WebSocketID.self)
                
            }
        }
        .ifLet(\.sideMenuFeature, action: /Action.sideMenuAction) {
            SideMenuFeature()
        }
        .ifLet(\.serviceAcceptFeature, action: /Action.serviceAcceptAction) {
            ServiceAcceptFeature()
        }
        .ifLet(\.mapFeature, action: /Action.mapAction) {
            MapFeature()
        }
    }
}
