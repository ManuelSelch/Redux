import Pulse

class Logger {
    static func log(_ msg: String) {
        LoggerStore.shared.storeMessage(
            label: "log",
            level: .debug,
            message: msg
        )
    }
    
    static func formatAction<Action>(_ action: Action) -> String {
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
