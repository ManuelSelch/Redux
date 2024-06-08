import Redux

struct SubFeature: Reducer {
    struct State: Equatable {
        
    }
    
    enum Action: Equatable {
        case buttonTapped
    }
    
    func reduce(_ state: inout State, _ action: Action) -> Effect<Action> {
        return .none
    }
}
