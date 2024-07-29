import Foundation

public class Listener {
    var emitAckListener : [Int : (String, (String, AnyObject?, AnyObject? ) -> Void )]
    var onListener :[String : (String, AnyObject?) -> Void]

    public init() {
        emitAckListener = [:]
        onListener = [:]
    }

    func putEmitAck(id : Int, eventName : String, ack : @escaping (String, AnyObject?, AnyObject? ) -> Void )
    {
        self.emitAckListener[id] = (eventName, ack)
    }
    
    func handleEmitAck (id : Int, error : AnyObject?, data : AnyObject?) {
        if let ackobject = emitAckListener[id] {
            let eventName = ackobject.0
            let ack = ackobject.1
            ack(eventName, error, data)
        }
    }
    
    func putOnListener(eventName : String, onListener: @escaping (String, AnyObject?) -> Void) {
        self.onListener[eventName] = onListener
    }
    
    func handleOnListener (eventName : String, data : AnyObject?) {
        if let on = onListener[eventName] {
            on(eventName, data)
        }
    }
    


}
