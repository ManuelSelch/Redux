import Foundation
import Starscream

public class ScClient: Listener {
    var socket: WebSocket
    var currentId: Int = 0
    
    public var onConnect: (() -> ())?
    
    public init(url: String) {
        var request = URLRequest(url: URL(string: url)!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        
        
        super.init()
    }
    
    public func connect() {
        reset()
        
        socket.onEvent = { event in
            switch(event){
            case .connected(_): 
                Logger.debug("connected")
                if let onConnect = self.onConnect {
                    onConnect()
                }
            default: break
            }
        }
        
    
        /*
        socket.onConnect = {
            Logger.log("connected")
            if let onConnect = self.onConnect {
                onConnect()
            }
        }
        socket.onDisconnect = { error in
            Logger.log("disconnect with error \(error.debugDescription)")
        }
        
        socket.onText = self.onMessage
         */
        
        socket.connect()
    }
    
    func onMessage(_ text: String) {
        if(text == "") {
            Logger.debug("receiving ping, sending pong back")
            self.socket.write(string: "")
        } else {
            Logger.debug("receive: \(text)")
            
            if let messageObject = JSONConverter.deserializeString(message: text) {
                if let (data, rid, cid, eventName, error) = Parser.getMessageDetails(myMessage: messageObject) {
                    
                    let parseResult = Parser.parse(rid: rid, cid: cid, event: eventName)
                    
                    switch parseResult {
                    case .publish:
                        if let channel = data as? [String : Any],
                           let channelName = channel["channel"] as? String,
                           let channelData = channel["data"] as AnyObject?
                        {
                            handleOnListener(eventName: channelName, data: channelData)
                        }
                        break
                    case .removeToken:
                        break
                    case .setToken:
                        break
                    case .ackReceive:
                        self.handleEmitAck(id: rid!, error: error as AnyObject, data: data as AnyObject)
                    case .event:
                        break
                    
                    }
                    
                }
            }
            
        }
    }
    
    func reset() {
        currentId = 0
        emitAckListener = [:]
    }
    
    public func emitAck<Obj: Codable>(eventName: String, data: Obj, ack : @escaping (String, AnyObject?, AnyObject? ) -> Void) {
        let id = getAndIncrement()
        let eventDate = EventDataAck(event: eventName, data: data, cid: id)
        putEmitAck(id: id, eventName: eventName, ack: ack)
        send(eventDate)
    }
    
    public func emit<Obj: Codable>(eventName: String, data: Obj) {
        let eventDate = EventData(event: eventName, data: data)
        send(eventDate)
    }
    
    public func subscribe(channelName: String, ack : @escaping (String, AnyObject?) -> Void) {
        let eventData = EventDataAck(event: "#subscribe", data: AuthChannel(channel: channelName), cid: getAndIncrement())
        putOnListener(eventName: channelName, onListener: ack)
        send(eventData)
    }
    
    func send<Obj: Encodable>(_ msg: Obj) {
        if let data = try? JSONEncoder().encode(msg),
           let json = String(data: data, encoding: String.Encoding.utf8)
        {
            Logger.debug("send: \(json)")
            socket.write(string: json)
        } else {
            Logger.error("error encoding message: \(msg)")
        }
        
    }

}

extension ScClient {
    struct EventData<Obj: Encodable>: Encodable {
        let event: String
        let data: Obj
    }
    
    struct EventDataAck<Obj: Encodable>: Encodable {
        let event: String
        let data: Obj
        let cid: Int
    }
    
    struct AuthChannel : Encodable {
        var channel : String
    }
    
    func getAndIncrement() -> Int {
        currentId += 1
        return currentId
    }
}
