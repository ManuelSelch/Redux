import SwiftUI

public protocol Router: ObservableObject {
    associatedtype Route
    
    var routes: [Route] {get set}
}

public extension Router {
    func navigate(_ route: Route){
        routes.append(route)
    }
    
    func back(){
        routes.removeLast()
    }
}
