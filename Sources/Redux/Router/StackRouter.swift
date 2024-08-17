public struct StackRouter<Route: Equatable & Hashable & Identifiable & Codable>: Equatable, Codable {
    public var root: Route
    public var stack: [Route] = []
    
    
    public init(root: Route){
        self.root = root
    }
    
    public var currentRoute: Route {
        return stack.last ?? root
    }
    
    
    public mutating func push(_ route: Route) {
        stack.append(route)
    }
    
    public mutating func presentRoot(_ route: Route) {
        root = route
        stack = []
    }
    
    public mutating func updateRoutes(_ routes: [Route]) {
        stack = routes
    }
    
    public mutating func dismiss() {
        stack.popLast()
    }
    
    public mutating func goBackToRoot() {
        stack = []
    }
}


