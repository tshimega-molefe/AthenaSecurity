//
//  WebSocketClient.swift
//  AthenaSecurity
//
//  Created by Tshimega Belmont on 2022/11/21.
//

import Foundation

final class WebsocketClient: NSObject {
    
    var webSocket: URLSessionWebSocketTask?
    var opened = false
    let accessToken: String
    static let shared = WebsocketClient()
    
    private var urlString = "ws://localhost:8000"
    
    private override init() {
        if let data = KeychainHelper.standard.read(service: "access-token"){
            if let accessToken = String(data: data, encoding: .utf8){
                self.accessToken = accessToken
            }
            else {
                self.accessToken = ""
                print("DEBUG: Something went wrong setting access token string value")
            }
        }
        else {
            self.accessToken = ""
            print("DEBUG: No webSocket access token found in keychain")
        }
    }
    
    func openWebSocket() {
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            
            print("DEBUG: AccessToken for WebSocket is \(String(describing: accessToken))")
            request.addValue(accessToken, forHTTPHeaderField: "Authorization")
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            let webSocket = session.webSocketTask(with: request)
            self.webSocket = webSocket
            opened = true
            self.webSocket?.resume()
        }
        else {
            webSocket = nil
        }
    }
    
    func pingWebSocket() {
        webSocket?.sendPing { error in
            if let error = error {
                print("DEBUG: Ping Error is \(error)")
            }
        }
    }
    
    func closeWebSocket() {
        webSocket?.cancel(with: .goingAway, reason: "DEBUG: Web Socket Session Ended..".data(using: .utf8))
    }
    
    func sendMessage(type: String, message: String) {
        let json = """
                    {
                        "type": "\(type)",
                        "data": "\(message)"
                    }
                    """
        DispatchQueue.global().asyncAfter(deadline: .now()+1) {
            
            self.webSocket?.send(.string(json), completionHandler: { error in
                if let error = error {
                    print("DEBUG: Send Message Error is \(error)")
                }
            })
        }
    }
    
    func receiveMessage() {
        webSocket?.receive(completionHandler: { [weak self] result in
            print(result)
            switch result {
                case .success(let message):
                    switch message {
                    case .data(let data):
                        print("DEBUG: Received Data: \(data)")
                    case .string(let message):
                        print("DEBUG: Recieved String: \(message)")
                    @unknown default:
                        break
                    }
                case .failure(let error):
                    print("DEBUG: Receive Message Error is \(error)")
            }
            self?.receiveMessage()
        })
    }
}

extension WebsocketClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("DEBUG: Opened websocket connection")
        opened = true
        receiveMessage()
    }
    
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("DEBUG: Closed websocket connection.")
        self.webSocket = nil
        self.opened = false
    }
}
