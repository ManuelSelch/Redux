public protocol ViewModel<State, Action, DState, DAction> {
    associatedtype State: ViewState<DState>
    associatedtype Action: ViewAction<DAction>
    
    associatedtype DState: Equatable
    associatedtype DAction: Equatable
    
    typealias ViewStore = Store<State, Action>
}

public protocol ViewState<DState>: Equatable {
    associatedtype DState: Equatable
    
    static func from(_ state: DState) -> Self
}

public protocol ViewAction<DAction>: Equatable {
    associatedtype DAction: Equatable
    
    var lifted: DAction {get}
}

public extension Store {
    func projection
    <
        ViewState,
        ViewAction,
        Component: ViewModel<ViewState, ViewAction, State, Action>
    >
    (_ viewModel: Component.Type) -> Store<ViewState, ViewAction>
    {
        return self.lift({ViewState.from($0)}, \ViewAction.lifted)
    }
}

