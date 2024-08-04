import Foundation
import Combine
import AnyCodable

import Redux

public class MonitorMiddleware<Action: Codable, State: Codable & Equatable> {
    public enum ActionType {
        case reset
        case jumpTo(State)
    }

    private var offlineActions: [Action] = []
    private var offlineStates: [State] = []
    
    private var client: ScClient
    
    private var subject: PassthroughSubject<Action, Never>
    private var cancellables: Set<AnyCancellable> = []
    
    private var isRemoteSetup = false
     
    private var onAction: (ActionType) -> (Action)
    private var showAction: (Action) -> (Bool)
    
    private var lastState: State
    private var lastCommit: State?

    public init(currentState: State, onAction: @escaping (ActionType) -> (Action), showAction: @escaping (Action) -> (Bool)) {
        self.lastState = currentState
        self.onAction = onAction
        self.showAction = showAction
        
        self.subject = PassthroughSubject<Action, Never>()
        
        self.client = .init(url: "wss://redux.dev.manuelselch.de/socketcluster/")
        self.client.onConnect = onConnect
        client.connect()
    }
    
    private func onConnect() {
        reset()
        client.emitAck(eventName: "#handshake", data: "", ack: self.onHandshake)
    }
   
    private func onHandshake(_ eventName: String, _ error: AnyObject?, _ data: AnyObject?) {
        Logger.debug("on handshake")
        client.emitAck(eventName: "login", data: "master", ack: onLogin)
    }
    
    private func onLogin(_ eventName: String, _ error: AnyObject?, _ data: AnyObject?) {
        Logger.debug("on login")
        if let channel = data as? String {
            client.subscribe(channelName: channel, ack: onMessage)
            sendInit()
            sendOfflineActions()
        }
    }
    
    private func reset() {
        lastCommit = nil
    }
    
    private func onMessage(_ eventName: String, _ data: AnyObject?) {
        Logger.debug("on respond channel message")
        if let dataObj = data as? [String : Any],
           let type = dataObj["type"] as? String
        {
            switch(type) {
            case "DISPATCH":
                if let actionObj = dataObj["action"] as? [String: Any],
                   let actionType = actionObj["type"] as? String
                {
                    switch(actionType) {
                    case "RESET":
                        handleAction(.reset)
                        reset()
                        sendInit()
                    case "COMMIT":
                        sendInit()
                    case "ROLLBACK":
                        if let commit = lastCommit {
                            handleAction(.jumpTo(commit))
                            sendInit(commit: false)
                        }
                       
                    case "JUMP_TO_ACTION":
                        guard
                            let stateDataString = dataObj["state"] as? String
                        else {
                            Logger.debug("no state string")
                            break
                        }
                        
                        guard
                            let stateData = stateDataString.data(using: .utf8)
                        else {
                            Logger.debug("no state data")
                            break
                        }
                        
                        do {
                            let newState = try JSONDecoder().decode(State.self, from: stateData)
                            handleAction(.jumpTo(newState))
                        } catch DecodingError.dataCorrupted(let context) {
                            Logger.error(context.debugDescription)
                        } catch DecodingError.keyNotFound(let key, let context) {
                            Logger.error("Key '\(key)' not found: \(context.debugDescription)")
                            Logger.error("codingPath: \(context.codingPath)")
                        } catch DecodingError.valueNotFound(let value, let context) {
                            Logger.error("Value '\(value)' not found: \(context.debugDescription)")
                            Logger.error("codingPath: \(context.codingPath)")
                        } catch DecodingError.typeMismatch(let type, let context) {
                            Logger.error("Type '\(type)' mismatch: \(context.debugDescription)")
                            Logger.error("codingPath: \(context.codingPath)")
                        } catch {
                            Logger.error("error: \(error.localizedDescription)")
                        }
                    default:
                        break
                    }
                }
            default:
                break
            }
        }
    }
    
    private func handleAction(_ actionType: ActionType) {
        let action = onAction(actionType)
        subject.send(action)
    }
    
    public func handle(_ state: State, _ action: Action) -> AnyPublisher<Action, Never> {
        lastState = state
        
        if(!isRemoteSetup) {
            isRemoteSetup = true
            return subject.eraseToAnyPublisher()
        }
        
        if(showAction(action)) {
            sendAction(action, state)
        }
        
        return .none
    }
}


private extension MonitorMiddleware {
    func sendOfflineActions() {
        if(client.isConnected) {
            while !offlineActions.isEmpty && !offlineStates.isEmpty {
                let action = offlineActions.removeLast()
                let state = offlineStates.removeLast()
                
                sendAction(action, state)
            }
        }
    }
    
    func sendAction(_ action: Action, _ state: State) {
        if(!client.isConnected) {
            offlineActions.append(action)
            offlineStates.append(state)
            return
        }
        
        let data = [
            "type": "ACTION",
            "action": [
                "action": [
                    "type": Logger.formatAction(action),
                    "action": action
                ],
                "timestamp": Date.now.timeIntervalSince1970
            ],
            "payload": state,
            "instanceId": "MyID"
        ] as AnyCodable
        
        client.emit(eventName: "log", data: data)
    }
    
    func sendInit(commit: Bool = true) {
        if(commit) {
            lastCommit = lastState
        }
        
        let data = [
            "type": "INIT",
            "payload": lastState,
            "instanceId": "MyID"
        ] as AnyCodable
        
        client.emit(eventName: "log", data: data)
    }
}
