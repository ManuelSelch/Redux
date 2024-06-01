import Foundation
import Combine
import SwiftUI


public struct RouterFeature<Route: Equatable & Hashable & Identifiable >: Reducer, Codable {
    public init() {}
    
    public enum Action {
        case updateRoutes([Route])
        case updateSheet(Route?)
    }
    
    public struct State: Equatable {
        var root: Route
        var routes: [Route] = []
        var sheet: Route?
        
        public init(root: Route){
            self.root = root
        }
        
        public mutating func presentSheet(_ route: Route) {
            self.sheet = route
        }
        
        public mutating func presentCover(_ route: Route) {
            self.root = route
            self.routes = []
        }
        
        public mutating func dismiss() {
            if sheet != nil {
                sheet = nil
            } else if !routes.isEmpty {
                routes.removeLast()
            }
        }
        
        public mutating func push(_ route: Route) {
            routes.append(route)
        }
        
    }

    public func reduce(_ state: inout State, _ action: Action) -> AnyPublisher<Action, Error> {

        switch(action) {
        case let .updateRoutes(routes):
            state.routes = routes
        case let .updateSheet(route):
            state.sheet = route
        }
        
        return Empty().eraseToAnyPublisher()


    }
    
}




