import Foundation

public enum MessageType {
    case publish
    case removeToken
    case setToken
    case event
    case ackReceive
}

public class Parser {
    
    public static func parse(rid : Int?, cid : Int?, event : String?) -> MessageType {
        if (event != nil) {
            if (event == "#publish") {
                return MessageType.publish
            } else if (event == "#removeAuthToken") {
                return MessageType.removeToken
            } else if (event == "#setAuthToken") {
                return MessageType.setToken
            } else {
                return MessageType.event
            }
        } else {
            return MessageType.ackReceive
        }
    }
    
    public static func getMessageDetails(myMessage : Any) -> (data: Any?, rid : Int?, cid : Int?, eventName : String?, error : Any?)? {
        if let messageItem = myMessage as? [String: Any] {
            let data = messageItem["data"]
            let rid = messageItem["rid"] as? Int
            let cid = messageItem["cid"] as? Int
            let event = messageItem["event"] as? String
            let error = messageItem["error"]
            return (data, rid, cid, event, error)
        }
        return nil
        
    }
}



public class JSONConverter {
    
    public static func deserializeString(message : String) -> [String : Any]? {
        let jsonObject = try? JSONSerialization.jsonObject(with: message.data(using: .utf8)!, options: [])
        return jsonObject as? [String : Any]
    }
    
    public static func deserializeData(data : Data) -> [String : Any]? {
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
        return jsonObject as? [String : Any]
    }
    
    public static func serializeObject(object : Any) -> String? {
        let message = try? JSONSerialization.data(withJSONObject: object, options: [])
        return String(data: message!, encoding: .utf8)
    }
}

public class ClientUtils {
    
    public static func getAuthToken(message : Any?) -> String? {
        if let items = message as? [String : Any] {
            if let data = items["data"] as? [String : Any] {
                return data["token"] as? String
            }
        }
        return nil
    }
    
    public static func getIsAuthenticated(message : Any?) -> Bool? {
        
        if let items = message as? [String : Any] {
            if let data = items["data"] as? [String : Any] {
                return data["isAuthenticated"] as? Bool
            }
        }
        return nil
    }
    
}
