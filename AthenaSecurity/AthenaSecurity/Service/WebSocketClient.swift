import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay

struct WebSocketClientComposable {
    enum Action: Equatable {
        case didOpen(protocol: String?)
        case didClose(code: URLSessionWebSocketTask.CloseCode, reason: Data?)
    }
    
    enum Message: Equatable {
        struct Unknown: Error {}
        
        
        case data(Data)
        case string(String)
        
        
        init(_ message: URLSessionWebSocketTask.Message) throws {
            switch message {
                
            case let .data(data): self = .data(data)
            case let .string(string): self = .string(string)
            @unknown default: throw Unknown()
            }
        }
    }
    
    var open: @Sendable (Any.Type, URL, [String]) async -> AsyncStream<Action>
    var receive: @Sendable (Any.Type) async throws -> AsyncStream<TaskResult<Message>>
    var send: @Sendable (Any.Type, URLSessionWebSocketTask.Message) async throws -> Void
    var sendPing: @Sendable (Any.Type) async throws -> Void
}

extension WebSocketClientComposable {
    static var live: Self {
        
        final actor WebSocketActor: GlobalActor {
            final class Delegate: NSObject, URLSessionWebSocketDelegate {
                var continuation: AsyncStream<Action>.Continuation?
                
                func urlSession(
                    _: URLSession,
                    webSocketTask _: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?
                ) {
                    self.continuation?.yield(.didOpen(protocol: `protocol`))
                }
                
                func urlSession(
                    _: URLSession,
                    webSocketTask _: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?
                ) {
                    self.continuation?.yield(.didClose(code: closeCode, reason: reason))
                    self.continuation?.finish()
                }
            }
            
            typealias Dependencies = (socket: URLSessionWebSocketTask, delegate: Delegate)
            
            static let shared = WebSocketActor()
            
            var dependencies: [ObjectIdentifier: Dependencies] = [:]
            
            func open(id: Any.Type, url: URL, protocols: [String]) -> AsyncStream<Action> {
                let id = ObjectIdentifier(id)
                let delegate = Delegate()
                            
                let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
                let socket = session.webSocketTask(with: url, protocols: protocols)
                defer { socket.resume() }
                var continuation: AsyncStream<Action>.Continuation!
                let stream = AsyncStream<Action> {
                    $0.onTermination = { _ in
                        socket.cancel()
                        Task { await self.removeDependencies(id: id) }
                    }
                    continuation = $0
                }
                delegate.continuation = continuation
                self.dependencies[id] = (socket, delegate)
                return stream
            }
            
            func close(
                id: Any.Type, with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?
            ) async throws {
                let id = ObjectIdentifier(id)
                defer { self.dependencies[id] = nil }
                try self.socket(id: id).cancel(with: closeCode, reason: reason)
            }
            
            func receive(id: Any.Type) throws -> AsyncStream<TaskResult<Message>> {
                let socket = try self.socket(id: ObjectIdentifier(id))
                return AsyncStream { continuation in
                    let task = Task {
                        while !Task.isCancelled {
                            continuation.yield(await TaskResult { try await Message(socket.receive()) })
                        }
                        continuation.finish()
                    }
                    continuation.onTermination = { _ in task.cancel() }
                }
            }
            
            func send(id: Any.Type, message: URLSessionWebSocketTask.Message) async throws {
                try await self.socket(id: ObjectIdentifier(id)).send(message)
            }
            
            func sendPing(id: Any.Type) async throws {
                let socket = try self.socket(id: ObjectIdentifier(id))
                return try await withCheckedThrowingContinuation { continuation in
                    socket.sendPing { error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume()
                        }
                    }
                }
            }
            
            private func socket(id: ObjectIdentifier) throws -> URLSessionWebSocketTask {
                guard let dependencies = self.dependencies[id]?.socket else {
                    struct Closed: Error {}
                    throw Closed()
                }
                return dependencies
            }
            
            private func removeDependencies(id: ObjectIdentifier) {
                self.dependencies[id] = nil
            }
        }
        
        return Self(
            open: { await WebSocketActor.shared.open(id: $0, url: $1, protocols: $2) },
            receive: { try await WebSocketActor.shared.receive(id: $0) },
            send: { try await WebSocketActor.shared.send(id: $0, message: $1) },
            sendPing: { try await WebSocketActor.shared.sendPing(id: $0) }
        )
    }
}



private enum WebsocketClientKey: DependencyKey {
    static var liveValue = WebSocketClientComposable.live
}

extension DependencyValues {
    var websocket: WebSocketClientComposable {
        get { self[WebsocketClientKey.self] }
        set { self[WebsocketClientKey.self] = newValue }
    }
}
