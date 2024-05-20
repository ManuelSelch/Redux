import Foundation
import Combine

public struct RouteModule<Route: Codable & Equatable>: Reducer, Codable {
    public enum Action: Codable {
        case push(Route)
        case set([Route])
        case pop
        
        case presentSheet(Route)
        case dismissSheet
    }
    
    public struct State: Codable, Equatable {
        public var routes: [Route] = []
        public var sheet: Route?
        
        public init(){}
    }
    
    public struct Dependency {
        public init(){}
    }
    
    public static func reduce(_ state: inout State, _ action: Action, _ env: Dependency) -> AnyPublisher<Action, Error> {

        switch(action){
        case .push(let route):
            state.routes.append(route)
        case .pop:
            state.routes.removeLast()
        case .set(let routes):
            state.routes = routes
        case .presentSheet(let route):
            state.sheet = route
        case .dismissSheet:
            state.sheet = nil
        }
        
        return Empty().eraseToAnyPublisher()


    }
    
}



