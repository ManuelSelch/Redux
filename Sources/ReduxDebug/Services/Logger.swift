import Pulse

public class Logger {
    public static func trace(_ msg: String){
        Self.log(msg, .trace)
    }
    
    public static func debug(_ msg: String){
        Self.log(msg, .debug)
    }
    
    public static func waring(_ msg: String){
        Self.log(msg, .warning)
    }
    
    public static func error(_ msg: String){
        Self.log(msg, .error)
    }
    
    private static func log(_ msg: String, _ level: LoggerStore.Level) {
        LoggerStore.shared.storeMessage(
            label: "log",
            level: level,
            message: msg
        )
    }
    
    public static func formatAction<Action>(_ action: Action) -> String {
        let actionStr = "\(action)"
        print(actionStr)
        let methods = actionStr.split(separator: "(")
        var methodsFormatted: [String] = []
        for method in methods {
            if(
                method.contains(":") ||
                method.contains("\"") ||
                method.contains("-") ||
                method.contains("[") ||
                method.contains("]")
            ){
                continue // only show action but no data
            }
            
            if let methodFormatted = method.split(separator: ".").last {
                let strMethodFormatted = String(methodFormatted).replacing(")",with: "")
                if(
                    strMethodFormatted.split(separator: " ").count == 1
                ){
                    methodsFormatted.append(strMethodFormatted)
                }
            }
        
        }
        
        var actionFormatted = ""
        for method in methodsFormatted {
            actionFormatted += "." + method
        }
        
        return actionFormatted
    }
}
