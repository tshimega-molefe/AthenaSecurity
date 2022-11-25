//
//  HomeScreenFeature.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import Foundation
import ComposableArchitecture

struct HomeScreenFeature: ReducerProtocol {
    
    struct State: Equatable {
        var showMenu = false
        var onDuty = false
        var connectivityState = ConnectivityState.disconnected
        var serviceAcceptFeature: ServiceAcceptFeature.State?
        var sideMenuFeature: SideMenuFeature.State?

        var emergency: EmergencyModel?
        var mapFeature: MapFeature.State?
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
                let messageToSend = "{\"type\": \"accept.emergency\", \"id\": \"\(state.emergency?.id ?? "")\"}"
                return .task {
                    print("DEBUG: SENDING ACCEPTION: \(messageToSend)")
                    try await websocket.send(WebSocketID.self, .string(messageToSend))
                    return .sendResponse(didSucceed: true)
                } catch: { _ in
                        .sendResponse(didSucceed: false)
                }
                .cancellable(id: WebSocketID.self)
                
            case .serviceAcceptAction(.getDirections):
                return .none
                
            case .serviceAcceptAction(.arrive):
                let messageToSend = "{\"type\": \"start.emergency\", \"id\": \"\(state.emergency?.id ?? "")\"}"
                return .task {
                    print("DEBUG: SENDING STARTINGs: \(messageToSend)")
                    try await websocket.send(WebSocketID.self, .string(messageToSend))
                    return .sendResponse(didSucceed: true)
                } catch: { _ in
                        .sendResponse(didSucceed: false)
                }
                .cancellable(id: WebSocketID.self)
                
            case .serviceAcceptAction(.complete):
                state.serviceAcceptFeature = nil
                let messageToSend = "{\"type\": \"complete.emergency\", \"id\": \"\(state.emergency?.id ?? "")\"}"
                return .task {
                    print("DEBUG: SENDING COMPLETION: \(messageToSend)")
                    try await websocket.send(WebSocketID.self, .string(messageToSend))
                    return .sendResponse(didSucceed: true)
                } catch: { _ in
                        .sendResponse(didSucceed: false)
                }
                .cancellable(id: WebSocketID.self)
                
                // MARK: - Map Feature Actions
                
            case .mapAction(.showUser):
                return .none
                
            case .mapAction(.getDirections):
                return .none
                
            case .mapAction(.trackUser):
                return .none
                
            case .mapAction(.removeUser):
                return .none
                
                // When the home Screen Feature appears.
                
            case .onAppear:
                return .none
                
            case .cancel:
                //state.serviceAcceptFeature = nil
                return .none
                
                // state.serviceAcceptFeature = nil
//                state.isPresented = false
//                return .none
                
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
                    
                    print(string)
                    let decoder = JSONDecoder()
                    state.emergency = try! decoder.decode(EmergencyModel.self, from: string.data(using: .utf8)!)
                    
                    let type = state.emergency?.type ?? ""
                    
                    switch type {
                    
                    case "create.emergency":
                        state.serviceAcceptFeature = ServiceAcceptFeature.State()
                        
                    case "cancel.emergency":
                        print("CANCELLED")
                        state.serviceAcceptFeature = nil
                        
                    case "start.emergency":
                        return .none
                        
                    case "complete.emergency":
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
