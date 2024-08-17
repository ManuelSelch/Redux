public struct AppRouterFeature<
    Route: Equatable & Hashable & Identifiable & Codable,
    TabRoute: Equatable & Hashable & Codable & Identifiable & CaseIterable
>: Reducer {
    public init() {}
    
    public struct State: Codable, Equatable {
        public init(screen: Screen, routers: [Screen:StackRouter<Route>]) {
            self.screen = screen
            self.routers = routers
        }
        
        var screen: Screen
        var sheet: StackRouter<Route>?
        var popup: Route?
        var routers: [Screen:StackRouter<Route>]
        
        /// current tab or root router
        public var currentRouter: StackRouter<Route> {
            return routers[screen]!
        }
        
        /// push route to current router or sheet
        public mutating func push(_ route: Route) {
            if sheet != nil {
                sheet?.push(route)
            } else {
                routers[screen]?.push(route)
            }
        }
        
        /// present sheet router
        public mutating func presentSheet(_ route: Route) {
            sheet = .init(root: route)
        }
        
        /// present popup router
        public mutating func presentPopup(_ route: Route) {
            popup = route
        }
        
        /// set root of current router
        private mutating func presentCover(_ route: Route) {
            routers[screen]?.presentRoot(route)
            sheet = nil
        }
        
        /// show root router with given route
        public mutating func presentRootScreen(_ route: Route) {
            screen = .root
            presentCover(route)
        }
        
        /// show tab router with given route
        public mutating func presentTabScreen(_ tab: TabRoute, route: Route) {
            screen = .tab(tab)
            presentCover(route)
        }
        
        /// hides sheet or pops stack route of current router
        public mutating func dismiss() {
            if popup != nil {
                popup = nil
            }
            else if sheet != nil {
                sheet = nil
            } else {
                routers[screen]?.dismiss()
            }
        }
        
        /// hides sheet or pops stack route of current router
        public mutating func goBackToRoot() {
            if sheet != nil {
                sheet?.goBackToRoot()
            } else {
                routers[screen]?.goBackToRoot()
            }
        }
    }
    
    public enum Screen: Codable, Equatable, Hashable {
        case root
        case tab(TabRoute)
    }
    
    public enum Action: Codable, Equatable {
        case updateScreen(Screen)
        case updateRoutes([Route])
        case updateSheet(Route?)
        case updatePopup(Route?)
    }
    
    public func reduce(_ state: inout State, _ action: Action) -> Effect<Action> {
        switch(action) {
        
        case let .updateScreen(screen):
            state.screen = screen
        case let .updateRoutes(routes):
           if state.sheet != nil {
                state.sheet?.updateRoutes(routes)
            } else {
                state.routers[state.screen]?.updateRoutes(routes)
            }
        case let .updateSheet(route):
            if let route = route {
                state.sheet = .init(root: route)
            } else {
                state.sheet = nil
            }
            
        case let .updatePopup(route):
            if let route = route {
                state.popup = route
            } else {
                state.popup = nil
            }
        }
        
        return .none
    }
}

