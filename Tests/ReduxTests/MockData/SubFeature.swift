import Redux

struct SubFeature: Reducer {
    struct State: Equatable {
        var route: SubRoute = .route1("")
        
        var sub: SubSubFeature.State
    }
    
    enum Action: Equatable {
        case buttonTapped
        
        case sub(SubSubFeature.Action)
    }
    
    enum SubRoute: Equatable {
        case route1(String)
        case route2(String)
    }
    
    func reduce(_ state: inout State, _ action: Action) -> Effect<Action> {
        switch(action) {
        case .buttonTapped:
            break
        case let .sub(action):
            return SubSubFeature().lift(&state.sub, action, toParent: Action.sub)
                
               
        }
        return .none
    }
}

struct SubSubFeature: Reducer {
    struct State: Equatable {
        
    }
    
    enum Action: Equatable {
        case subSubAction
    }
    
    func reduce(_ state: inout State, _ action: Action) -> Effect<Action> {
        return .none
    }
}
